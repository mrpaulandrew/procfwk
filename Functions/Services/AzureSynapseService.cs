using System;
using System.Threading;
using System.Collections.Generic;
using Newtonsoft.Json;
using Microsoft.Rest;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Azure.Management.Synapse;
using Azure.Core;
using Azure.Identity;
using Azure.Analytics.Synapse.Artifacts;
using Azure.Analytics.Synapse.Artifacts.Models;
using mrpaulandrew.azure.procfwk.Helpers;

namespace mrpaulandrew.azure.procfwk.Services
{
    public class AzureSynapseService : PipelineService
    {
        private readonly SynapseManagementClient _synManagementClient;
        private readonly PipelineClient _pipelineClient;
        private readonly PipelineRunClient _pipelineRunClient;
        private readonly ILogger _logger;
        
        public AzureSynapseService(PipelineRequest request, ILogger logger)
        {
            _logger = logger;
            _logger.LogInformation("Creating SYN connectivity clients.");

            //Auth details
            var context = new AuthenticationContext("https://login.windows.net/" + request.TenantId);
            var cc = new ClientCredential(request.ApplicationId, request.AuthenticationKey);
            var result = context.AcquireTokenAsync("https://management.azure.com/", cc).Result;
            var cred = new TokenCredentials(result.AccessToken);

            //Management Client
            _synManagementClient = new SynapseManagementClient(cred)
            {
                SubscriptionId = request.SubscriptionId
            };

            //Pipeline Clients
            Uri synapseDevEndpoint = new Uri("https://" + request.OrchestratorName.ToLower() + ".dev.azuresynapse.net");
            TokenCredential token = new ClientSecretCredential
                (
                request.TenantId,
                request.ApplicationId,
                request.AuthenticationKey
                );

            _pipelineClient = new PipelineClient(synapseDevEndpoint, token);
            _pipelineRunClient = new PipelineRunClient(synapseDevEndpoint, token);
        }

        public override PipelineDescription ValidatePipeline(PipelineRequest request)
        {
            _logger.LogInformation("Validating SYN pipeline.");

            PipelineResource pipelineResource;

            try
            {
                pipelineResource = _pipelineClient.GetPipeline
                    (
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
            catch (System.InvalidOperationException) //for bug in underlying activity classes, pipeline does exist
            {
                return new PipelineDescription()
                {
                    PipelineExists = "True",
                    PipelineName = request.PipelineName,
                    PipelineId = "Unknown",
                    PipelineType = "Unknown",
                    ActivityCount = 0
                }; 
            }
            catch (Azure.RequestFailedException) //expected exception when pipeline doesnt exist
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

            CreateRunResponse runResponse;
            runResponse = _pipelineClient.CreatePipelineRun
                (
                request.PipelineName,
                parameters: request.ParametersAsObjects
                );

            _logger.LogInformation("Pipeline run ID: " + runResponse.RunId);

            //Wait and check for pipeline to start...
            PipelineRun pipelineRun;
            _logger.LogInformation("Checking ADF pipeline status.");
            while (true)
            {
                pipelineRun = _pipelineRunClient.GetPipelineRun
                    (
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
            _logger.LogInformation("Getting SYN pipeline current status.");

            PipelineRun pipelineRun;
            pipelineRun = _pipelineRunClient.GetPipelineRun
                (
                request.RunId
                );

            //Defensive check
            PipelineNameCheck(request.PipelineName, pipelineRun.PipelineName);

            if (pipelineRun.Status == "InProgress" || pipelineRun.Status == "Queued")
            {
                _logger.LogInformation("Attempting to cancel SYN pipeline.");
                _pipelineRunClient.CancelPipelineRun
                    (
                    request.RunId,
                    isRecursive: request.RecursivePipelineCancel
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
                pipelineRun = _pipelineRunClient.GetPipelineRun
                    (
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
                ActualStatus = pipelineRun.Status
            };
        }

        public override PipelineRunStatus GetPipelineRunStatus(PipelineRunRequest request)
        {
            _logger.LogInformation("Getting SYN pipeline status.");

            //Get pipeline status with provided run id
            PipelineRun pipelineRun;
            pipelineRun = _pipelineRunClient.GetPipelineRun
                (
                request.RunId
                );

            //Defensive check
            PipelineNameCheck(request.PipelineName, pipelineRun.PipelineName);

            _logger.LogInformation("SYN pipeline status: " + pipelineRun.Status);

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
            PipelineRun pipelineRun = _pipelineRunClient.GetPipelineRun
                (
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

            _logger.LogInformation("Querying SYN pipeline for Activity Runs.");
            ActivityRunsQueryResponse queryResponse = _pipelineRunClient.QueryActivityRuns
                (
                request.PipelineName,
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
                var json = JsonConvert.SerializeObject(activity.Error);
                Dictionary<string, object> errorContent = JsonConvert.DeserializeObject<Dictionary<string, object>>(json);

                _logger.LogInformation("Activity run id: " + activity.ActivityRunId);
                _logger.LogInformation("Activity name: " + activity.ActivityName);
                _logger.LogInformation("Activity type: " + activity.ActivityType);
                _logger.LogInformation("Error message: " + errorContent["message"].ToString());

                output.Errors.Add(new FailedActivity()
                {
                    ActivityRunId = activity.ActivityRunId,
                    ActivityName = activity.ActivityName,
                    ActivityType = activity.ActivityType,
                    ErrorCode = errorContent["errorCode"].ToString(),
                    ErrorType = errorContent["failureType"].ToString(),
                    ErrorMessage = errorContent["message"].ToString()
                });
            }
            return output;
        }

        public override void Dispose()
        {
            _synManagementClient?.Dispose();
            //_pipelineClient?.Dispose(); not yet supported
            //_pipelineRunClient?.Dispose(); not yet supported
        }
    }
}
