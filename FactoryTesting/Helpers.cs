using Microsoft.Azure.Management.DataFactory;
using Microsoft.Azure.Management.DataFactory.Models;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Rest;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace FactoryTesting
{
    internal class Helpers
    {
        public string PipelineOutcome { get; private set; }
        public string TestRunId { get; private set; }
        public string ResourceGroupName { get; set; }
        public string FactoryName { get; set; }
        public string PipelineName { get; set; }

        private static DataFactoryManagementClient CreateDataFactoryClient()
        {
            var context = new AuthenticationContext("https://login.windows.net/" + Environment.GetEnvironmentVariable("AZURE_TENANT_ID"));

            ClientCredential cc = new ClientCredential(Environment.GetEnvironmentVariable("AZURE_CLIENT_ID"), Environment.GetEnvironmentVariable("AZURE_CLIENT_SECRET"));
            AuthenticationResult result = context.AcquireTokenAsync("https://management.azure.com/", cc).Result;
            ServiceClientCredentials cred = new TokenCredentials(result.AccessToken);

            var adfClient = new DataFactoryManagementClient(cred)
            {
                SubscriptionId = Environment.GetEnvironmentVariable("AZURE_SUBSCRIPTION_ID")
            };

            return adfClient;
        }

        public async Task StartPipelineRun()
        {
            PipelineOutcome = "Unknown";

            // prepare ADF client
            using (var adfClient = CreateDataFactoryClient())
            {
                // run pipeline
                var response = await adfClient.Pipelines.CreateRunWithHttpMessagesAsync(ResourceGroupName, FactoryName, PipelineName);
                TestRunId = response.Body.RunId;
                
                // wait for pipeline to finish
                var run = await adfClient.PipelineRuns.GetAsync(ResourceGroupName, FactoryName, TestRunId);
                while (run.Status == "Queued")
                {
                    Thread.Sleep(2000);
                    run = await adfClient.PipelineRuns.GetAsync(ResourceGroupName, FactoryName, TestRunId);
                }
                PipelineOutcome = run.Status;
            }
        }

        public async Task PipelineRunComplete(string RunId)
        {
            PipelineOutcome = "Unknown";

            using (var adfClient = CreateDataFactoryClient())
            {
                // wait for pipeline to finish
                var run = await adfClient.PipelineRuns.GetAsync(ResourceGroupName, FactoryName, RunId);
                while (run.Status == "Queued" || run.Status == "InProgress" || run.Status == "Canceling")
                {
                    Thread.Sleep(2000);
                    run = await adfClient.PipelineRuns.GetAsync(ResourceGroupName, FactoryName, RunId);
                }
                PipelineOutcome = run.Status;
            }
        }
    }
}
