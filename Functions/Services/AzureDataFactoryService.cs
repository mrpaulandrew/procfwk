using mrpaulandrew.azure.procfwk.Helpers;
using Microsoft.Azure.Management.DataFactory;
using Microsoft.Azure.Management.DataFactory.Models;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Rest;
using Newtonsoft.Json;
using System;
using System.Threading;

namespace mrpaulandrew.azure.procfwk.Services
{
    public class AzureDataFactoryService : PipelineService
    {
        private readonly DataFactoryManagementClient _adfClient;
        private readonly ILogger _logger;

        public AzureDataFactoryService(PipelineRequest request, ILogger logger)
        {
            _logger = logger;
            _logger.LogInformation("Creating ADF connectivity client.");

            var context = new AuthenticationContext("https://login.windows.net/" + request.TenantId);
            var cc = new ClientCredential(request.ApplicationId, request.AuthenticationKey);
            var result = context.AcquireTokenAsync("https://management.azure.com/", cc).Result;
            var cred = new TokenCredentials(result.AccessToken);

            _adfClient = new DataFactoryManagementClient(cred)
            {
                SubscriptionId = request.SubscriptionId
            };
        }

        public override void Dispose()
        {
            _adfClient?.Dispose();
        }

        public override object ValidatePipeline(PipelineRequest request)
        {
            try
            {
                var pipelineResource = _adfClient.Pipelines.Get
                    (
                    request.ResourceGroup, 
                    request.OrchestratorName, 
                    request.PipelineName
                    );
                
                _logger.LogInformation(pipelineResource.Id.ToString());
                _logger.LogInformation(pipelineResource.Name.ToString());

                return new PipelineDescription()
                {
                    PipelineExists = "True",
                    PipelineName = pipelineResource.Name,
                    PipelineId = pipelineResource.Id,
                    PipelineType = pipelineResource.Type,
                    ActivityCount = pipelineResource.Activities.Count
                };
            }
            catch (Exception ex)
            {
                _logger.LogInformation(ex.Message);
                return new PipelineNotExists()
                {
                    PipelineExists = "False",
                    ProvidedPipelineName = request.PipelineName
                };
            }
        }

        public override PipelineRunStatus ExecutePipeline(PipelineRequest request)
        {
            if (request.PipelineParameters == null)
                _logger.LogInformation("Calling pipeline without parameters.");
            else
                _logger.LogInformation("Calling pipeline with parameters.");

            var runResponse = _adfClient.Pipelines.CreateRunWithHttpMessagesAsync
                (
                request.ResourceGroup, 
                request.OrchestratorName, 
                request.PipelineName, 
                parameters: request.ParametersAsObjects
                ).Result.Body;

            _logger.LogInformation("Pipeline run ID: " + runResponse.RunId);

            //Wait and check for pipeline to start...
            PipelineRun pipelineRun;
            _logger.LogInformation("Checking ADF pipeline status.");
            while (true)
            {
                pipelineRun = _adfClient.PipelineRuns.Get
                    (
                    request.ResourceGroup, 
                    request.OrchestratorName,
                    runResponse.RunId
                    );

                _logger.LogInformation("ADF pipeline status: " + pipelineRun.Status);

                if (pipelineRun.Status != "Queued")
                    break;
                Thread.Sleep(15000);
            }

            return new PipelineRunStatus()
            {
                PipelineName = request.PipelineName,
                RunId = runResponse.RunId,
                Status = pipelineRun.Status
            };
        }

        public override PipelineRunStatus CancelPipeline(PipelineRequest request)
        {
            var runResponse = _adfClient.Pipelines.CreateRunWithHttpMessagesAsync
                (
                request.ResourceGroup,
                request.OrchestratorName,
                request.PipelineName,
                parameters: request.ParametersAsObjects
                ).Result.Body;

            _logger.LogInformation("Pipeline run ID: " + runResponse.RunId);

            
            PipelineRun pipelineRun;
            pipelineRun = _adfClient.PipelineRuns.Get
                (
                request.ResourceGroup,
                request.OrchestratorName,
                runResponse.RunId
                );

            if (pipelineRun.Status == "InProgress" || pipelineRun.Status == "Queued")
            {
                _adfClient.PipelineRuns.Cancel
                    (
                    request.ResourceGroup,
                    request.OrchestratorName,
                    runResponse.RunId,
                    true //recursive cancel
                    );
            }
            else
            {
                _logger.LogInformation("ADF pipeline status: " + pipelineRun.Status);
                throw new InvalidRequestException("Target pipeline is not in a state that can be cancelled.");
            }

            //wait for cancelled state
            _logger.LogInformation("Checking ADF pipeline status.");
            while (true)
            {
                pipelineRun = _adfClient.PipelineRuns.Get
                    (
                    request.ResourceGroup,
                    request.OrchestratorName,
                    runResponse.RunId
                    );

                _logger.LogInformation("ADF pipeline status: " + pipelineRun.Status);

                if (pipelineRun.Status == "Cancelling" || pipelineRun.Status == "Canceling") //microsoft typo
                    break;
                Thread.Sleep(15000);
            }

            //Final return detail
            return new PipelineRunStatus()
            {
                PipelineName = request.PipelineName,
                RunId = runResponse.RunId,
                Status = pipelineRun.Status
            };
        }

        public override PipelineRunStatus GetPipelineRunStatus(PipelineRunRequest request)
        {
            //Get pipeline status with provided run id
            var pipelineRun = _adfClient.PipelineRuns.Get
                (
                request.ResourceGroup, 
                request.OrchestratorName, 
                request.RunId
                );

            _logger.LogInformation("Checking ADF pipeline status.");

            //Create simple status for Data Factory Until comparison checks
            string simpleStatus;

            switch (pipelineRun.Status)
            {
                case "InProgress":
                    simpleStatus = "Running";
                    break;
                case "Canceling": //microsoft typo
                    simpleStatus = "Running";
                    break;
                case "Cancelling":
                    simpleStatus = "Running";
                    break;
                default:
                    simpleStatus = "Done";
                    break;
            }

            _logger.LogInformation("ADF pipeline status: " + pipelineRun.Status);

            //Final return detail
            return new PipelineRunStatus()
            {
                PipelineName = request.PipelineName,
                RunId = pipelineRun.RunId,
                SimpleStatus = simpleStatus,
                Status = pipelineRun.Status.Replace("Canceling", "Cancelling") //microsoft typo
            };
        }

        public override PipelineRunStatus GetPipelineRunActivityErrors(PipelineRunRequest request)
        {
            //Query and output support variables
            int daysOfRuns = 7; //max duration for mandatory RunFilterParameters
            DateTime today = DateTime.Now;
            DateTime lastWeek = DateTime.Now.AddDays(-daysOfRuns);

            var pipelineRun = _adfClient.PipelineRuns.Get
                (
                request.ResourceGroup, 
                request.OrchestratorName, 
                request.RunId
                );

            _logger.LogInformation("Querying ADF pipeline for Activity Runs.");
            RunFilterParameters filterParams = new RunFilterParameters(lastWeek, today);
            ActivityRunsQueryResponse queryResponse = _adfClient.ActivityRuns.QueryByPipelineRun
                (
                request.ResourceGroup, 
                request.OrchestratorName, 
                request.RunId, 
                filterParams
                );

            //Create initial output content
            var output = new PipelineRunStatus()
            {
                PipelineName = request.PipelineName,
                PipelineStatus = pipelineRun.Status,
                RunId = request.RunId,
                ResponseCount = queryResponse.Value.Count

            };

            _logger.LogInformation("Pipeline status: " + pipelineRun.Status);
            _logger.LogInformation("Activities found in pipeline response: " + queryResponse.Value.Count.ToString());

            //Loop over activities in pipeline run
            foreach (var activity in queryResponse.Value)
            {
                if (string.IsNullOrEmpty(activity.Error.ToString()))
                {
                    continue; //just incase
                }

                //Parse error output to customise output
                dynamic outputBlockInner = JsonConvert.DeserializeObject(activity.Error.ToString());
                string errorCode = outputBlockInner?.errorCode;
                string errorType = outputBlockInner?.failureType;
                string errorMessage = outputBlockInner?.message;

                //Get output details
                if (!string.IsNullOrEmpty(errorCode))
                {
                    _logger.LogInformation("Activity run id: " + activity.ActivityRunId);
                    _logger.LogInformation("Activity name: " + activity.ActivityName);
                    _logger.LogInformation("Activity type: " + activity.ActivityType);
                    _logger.LogInformation("Error message: " + errorMessage);

                    output.Errors.Add(new FailedActivity()
                    {
                        ActivityRunId = activity.ActivityRunId,
                        ActivityName = activity.ActivityName,
                        ActivityType = activity.ActivityType,
                        ErrorCode = errorCode,
                        ErrorType = errorType,
                        ErrorMessage = errorMessage
                    }
                    );
                }
            }

            return output;
        }
    }
}


