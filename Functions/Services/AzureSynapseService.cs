using System;
using Microsoft.Rest;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Azure.Management.Synapse;
using Azure.Core;
using Azure.Identity;
using Azure.Analytics.Synapse.Artifacts;
using mrpaulandrew.azure.procfwk.Helpers;
using Azure.Analytics.Synapse.Artifacts.Models;

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
            catch (Exception ex)
            {
                _logger.LogInformation(ex.Message);
                return new PipelineDescription()
                {
                    PipelineExists = "False",
                    PipelineName = request.PipelineName,
                    PipelineId = "Unknown",
                    PipelineType = "Unknown",
                    ActivityCount = 0
                };
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

            /*
             * 
             * Harden request with status checking and wait behaviour as per ADF version.
             * 
            */

            return new PipelineRunStatus()
            {
                PipelineName = request.PipelineName,
                RunId = runResponse.RunId,
                ActualStatus = "Unknown" //replace with actual value
            };
        }

        public override PipelineRunStatus CancelPipeline(PipelineRunRequest request)
        {
            _pipelineRunClient.CancelPipelineRun
                (
                request.RunId,
                isRecursive: request.RecursivePipelineCancel
                );

            /*
             * 
             * Harden request with status checking and wait behaviour as per ADF version.
             * 
            */

            //Final return detail
            return new PipelineRunStatus()
            {
                PipelineName = request.PipelineName,
                RunId = request.RunId,
                ActualStatus = "Unknown" //replace with actual value
            };
        }

        public override PipelineRunStatus GetPipelineRunStatus(PipelineRunRequest request)
        {
            _logger.LogInformation("Getting SYN pipeline status.");

            PipelineRun pipelineRun;
            pipelineRun = _pipelineRunClient.GetPipelineRun
                (
                request.RunId
                );

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
