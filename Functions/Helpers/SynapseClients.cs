using System;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Rest;
using Microsoft.Azure.Management.Synapse;
using Azure.Analytics.Synapse.Artifacts;
using Azure.Core;
using Azure.Identity;

namespace procfwk.Helpers
{
    internal class SynapseClients
    {
        public static SynapseManagementClient CreateManagemenClient(string tenantId, string applicationId, string authenticationKey, string subscriptionId)
        {
            var context = new AuthenticationContext("https://login.windows.net/" + tenantId);

            ClientCredential cc = new ClientCredential(applicationId, authenticationKey);
            AuthenticationResult result = context.AcquireTokenAsync("https://management.azure.com/", cc).Result;
            ServiceClientCredentials cred = new TokenCredentials(result.AccessToken);

            var synManagemenClient = new SynapseManagementClient(cred)
            {
                SubscriptionId = subscriptionId
            };

            return synManagemenClient;
        }

        public static PipelineRunClient CreatePipelineRunClient(string tenantId, string workspaceName, string applicationId, string authenticationKey)
        {
            Uri synapseEndpoint = new Uri("https://" + workspaceName + ".dev.azuresynapse.net");

            TokenCredential token = new ClientSecretCredential(tenantId, applicationId, authenticationKey);

            var pipelineRunClient = new PipelineRunClient(synapseEndpoint, token);

            return pipelineRunClient;
        }

        public static PipelineClient CreatePipelineClient(string tenantId, string workspaceName, string applicationId, string authenticationKey)
        {
            Uri synapseEndpoint = new Uri("https://" + workspaceName + ".dev.azuresynapse.net");

            TokenCredential token = new ClientSecretCredential(tenantId, applicationId, authenticationKey);

            var pipelineClient = new PipelineClient(synapseEndpoint, token);

            return pipelineClient;
        }
    }
}