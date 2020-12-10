using System;
using System.Threading;
using Microsoft.Rest;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Azure.Management.Synapse;
using Azure.Core;
using Azure.Identity;
using Azure.Analytics.Synapse.Artifacts;
using Azure.Analytics.Synapse.Artifacts.Models;
using mrpaulandrew.azure.procfwk.Helpers;
using Azure;

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

            //Management Client
            var context = new AuthenticationContext("https://login.windows.net/" + request.TenantId);
            var cc = new ClientCredential(request.ApplicationId, request.AuthenticationKey);
            var result = context.AcquireTokenAsync("https://management.azure.com/", cc).Result;
            var cred = new TokenCredentials(result.AccessToken);

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
            catch (Exception ex) //unknown issue
            {
                _logger.LogInformation(ex.Message);
                _logger.LogInformation(ex.GetType().ToString());
                _logger.LogInformation(ex.StackTrace);
                _logger.LogInformation(ex.Source);
                _logger.LogInformation(ex.HelpLink);

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

        public override PipelineFailStatus GetPipelineRunActivityErrors(PipelineRunRequest request)
        {
            throw new NotImplementedException();
        }

        public override void Dispose()
        {
            _synManagementClient?.Dispose();
            //_pipelineClient?.Dispose(); not yet supported
            //_pipelineRunClient?.Dispose(); not yet supported
        }
    }
}
