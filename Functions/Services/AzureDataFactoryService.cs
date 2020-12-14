using System;
using System.Threading;
using Newtonsoft.Json;
using Microsoft.Rest;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Azure.Management.DataFactory;
using Microsoft.Azure.Management.DataFactory.Models;
using mrpaulandrew.azure.procfwk.Helpers;

namespace mrpaulandrew.azure.procfwk.Services
{
    public class AzureDataFactoryService : PipelineService
    {
        private readonly DataFactoryManagementClient _adfManagementClient;
        private readonly ILogger _logger;

        public AzureDataFactoryService(PipelineRequest request, ILogger logger)
        {
            _logger = logger;
            _logger.LogInformation("Creating ADF connectivity clients.");

            //Auth details
            var context = new AuthenticationContext("https://login.windows.net/" + request.TenantId);
            var cc = new ClientCredential(request.ApplicationId, request.AuthenticationKey);
            var result = context.AcquireTokenAsync("https://management.azure.com/", cc).Result;
            var cred = new TokenCredentials(result.AccessToken);

            //Management Client
            _adfManagementClient = new DataFactoryManagementClient(cred)
            {
                SubscriptionId = request.SubscriptionId
            };
        }

        public override PipelineDescription ValidatePipeline(PipelineRequest request)
        {
            _logger.LogInformation("Validating ADF pipeline.");

            try
            {
                var pipelineResource = _adfManagementClient.Pipelines.Get
                    (
                    request.ResourceGroupName, 
                    request.OrchestratorName, 
                    request.PipelineName
                    );
                
                _logger.LogInformation(pipelineResource.Id.ToString());

                return new PipelineDescription()
                {
                    PipelineExists = "True",
                    PipelineName = pipelineResource.Name,
                    PipelineId = pipelineResource.Id,
                    PipelineType = pipelineResource.Type,
                    ActivityCount = pipelineResource.Activities.Count
                };
            }
            catch (Microsoft.Rest.Azure.CloudException) //expected exception when pipeline doesnt exist
            {
                return new PipelineDescription()
                {
                    PipelineExists = "False",
                    PipelineName = request.PipelineName,
                    PipelineId = "Unknown",
                    PipelineType = "Unknown",
                    ActivityCount = 0
                };
            }
            catch (Exception ex) //other unknown issue
            {
                _logger.LogInformation(ex.Message);
                _logger.LogInformation(ex.GetType().ToString());
                throw new InvalidRequestException("Failed to validate pipeline. ", ex);
            }
        }

        public override PipelineRunStatus ExecutePipeline(PipelineRequest request)
        {
            if (request.PipelineParameters == null)
                _logger.LogInformation("Calling pipeline without parameters.");
            else
                _logger.LogInformation("Calling pipeline with parameters.");

            var runResponse = _adfManagementClient.Pipelines.CreateRunWithHttpMessagesAsync
                (
                request.ResourceGroupName, 
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
                pipelineRun = _adfManagementClient.PipelineRuns.Get
                    (
                    request.ResourceGroupName, 
                    request.OrchestratorName,
                    runResponse.RunId
                    );

                _logger.LogInformation("Waiting for pipeline to start, current status: " + pipelineRun.Status);

                if (pipelineRun.Status != "Queued")
                    break;
                Thread.Sleep(internalWaitDuration);
            }

            return new PipelineRunStatus()
            {
                PipelineName = request.PipelineName,
                RunId = runResponse.RunId,
                ActualStatus = pipelineRun.Status
            };
        }

        public override PipelineRunStatus CancelPipeline(PipelineRunRequest request)
        {
            _logger.LogInformation("Getting ADF pipeline current status.");

            PipelineRun pipelineRun;
            pipelineRun = _adfManagementClient.PipelineRuns.Get
                (
                request.ResourceGroupName,
                request.OrchestratorName,
                request.RunId
                );

            //Defensive check
            PipelineNameCheck(request.PipelineName, pipelineRun.PipelineName);

            if (pipelineRun.Status == "InProgress" || pipelineRun.Status == "Queued")
            {
                _logger.LogInformation("Attempting to cancel ADF pipeline.");
                _adfManagementClient.PipelineRuns.Cancel
                    (
                    request.ResourceGroupName,
                    request.OrchestratorName,
                    request.RunId,
                    isRecursive : request.RecursivePipelineCancel
                    );
            }
            else
            {
                _logger.LogInformation("ADF pipeline status: " + pipelineRun.Status);
                throw new InvalidRequestException("Target pipeline is not in a state that can be cancelled.");
            }

            //wait for cancelled state
            _logger.LogInformation("Checking ADF pipeline status after cancel request.");
            while (true)
            {
                pipelineRun = _adfManagementClient.PipelineRuns.Get
                    (
                    request.ResourceGroupName,
                    request.OrchestratorName,
                    request.RunId
                    );

                _logger.LogInformation("Waiting for pipeline to cancel, current status: " + pipelineRun.Status);

                if (pipelineRun.Status == "Cancelled")
                    break;
                Thread.Sleep(internalWaitDuration);
            }

            //Final return detail
            return new PipelineRunStatus()
            {
                PipelineName = request.PipelineName,
                RunId = request.RunId,
                ActualStatus = pipelineRun.Status.Replace("Canceling", "Cancelling") //microsoft typo
            };
        }

        public override PipelineRunStatus GetPipelineRunStatus(PipelineRunRequest request)
        {
            _logger.LogInformation("Checking ADF pipeline status.");

            //Get pipeline status with provided run id
            PipelineRun pipelineRun;
            pipelineRun = _adfManagementClient.PipelineRuns.Get
                (
                request.ResourceGroupName, 
                request.OrchestratorName, 
                request.RunId
                );

            //Defensive check
            PipelineNameCheck(request.PipelineName, pipelineRun.PipelineName);

            _logger.LogInformation("ADF pipeline status: " + pipelineRun.Status);

            //Defensive check
            PipelineNameCheck(request.PipelineName, pipelineRun.PipelineName);

            //Final return detail
            return new PipelineRunStatus()
            {
                PipelineName = request.PipelineName,
                RunId = pipelineRun.RunId,
                ActualStatus = pipelineRun.Status.Replace("Canceling", "Cancelling") //microsoft typo
            };
        }

        public override PipelineErrorDetail GetPipelineRunActivityErrors(PipelineRunRequest request)
        {
            PipelineRun pipelineRun = _adfManagementClient.PipelineRuns.Get
                (
                request.ResourceGroupName, 
                request.OrchestratorName, 
                request.RunId
                );

            //Defensive check
            PipelineNameCheck(request.PipelineName, pipelineRun.PipelineName);

            _logger.LogInformation("Create pipeline Activity Runs query filters.");
            RunFilterParameters filterParams = new RunFilterParameters
                (
                request.ActivityQueryStart, 
                request.ActivityQueryEnd
                );

            _logger.LogInformation("Querying ADF pipeline for Activity Runs.");
            ActivityRunsQueryResponse queryResponse = _adfManagementClient.ActivityRuns.QueryByPipelineRun
                (
                request.ResourceGroupName, 
                request.OrchestratorName, 
                request.RunId, 
                filterParams
                );

            //Create initial output content
            PipelineErrorDetail output = new PipelineErrorDetail()
            {
                PipelineName = request.PipelineName,
                ActualStatus = pipelineRun.Status,
                RunId = request.RunId,
                ResponseCount = queryResponse.Value.Count
            };

            _logger.LogInformation("Pipeline status: " + pipelineRun.Status);
            _logger.LogInformation("Activities found in pipeline response: " + queryResponse.Value.Count.ToString());

            //Loop over activities in pipeline run
            foreach (ActivityRun activity in queryResponse.Value)
            {
                if (activity.Error == null)
                {
                    continue; //only want errors
                }

                //Parse error output to customise output
                dynamic outputBlockInner = JsonConvert.DeserializeObject(activity.Error.ToString());
                string errorCode = outputBlockInner?.errorCode;
                string errorType = outputBlockInner?.failureType;
                string errorMessage = outputBlockInner?.message;

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
                });
            }
            return output;
        }

        public override void Dispose()
        {
            _adfManagementClient?.Dispose();
        }
    }
}