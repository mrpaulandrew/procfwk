using System;
using System.Threading;
using Newtonsoft.Json;
using Microsoft.Rest;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Azure.Management.Synapse;
using Azure.Core;
using Azure.Identity;
using Azure.Analytics.Synapse.Artifacts;
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

        public override PipelineRunStatus CancelPipeline(PipelineRunRequest request)
        {
            throw new NotImplementedException();
        }

        public override PipelineRunStatus ExecutePipeline(PipelineRequest request)
        {
            throw new NotImplementedException();
        }

        public override PipelineRunStatus GetPipelineRunActivityErrors(PipelineRunRequest request)
        {
            throw new NotImplementedException();
        }

        public override PipelineRunStatus GetPipelineRunStatus(PipelineRunRequest request)
        {
            throw new NotImplementedException();
        }

        public override object ValidatePipeline(PipelineRequest request)
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
