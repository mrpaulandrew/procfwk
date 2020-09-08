using Microsoft.Azure.Management.DataFactory;
using Microsoft.Azure.Management.DataFactory.Models;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Rest;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Threading.Tasks;

namespace FactoryTesting.Helpers
{
    public class DataFactoryHelper<T> : SettingsHelper<T> where T : DataFactoryHelper<T>
    {
        private readonly string _adfName;
        private readonly string _rgName;
        private DataFactoryManagementClient _adfClient;

        private async Task InitialiseClient()
        {
            if (_adfClient != null)
                return;

            var context = new AuthenticationContext("https://login.windows.net/" + GetSetting("AZURE_TENANT_ID"));
            var cc = new ClientCredential(GetSetting("AZURE_CLIENT_ID"), GetSetting("AZURE_CLIENT_SECRET"));
            var authResult = await context.AcquireTokenAsync("https://management.azure.com/", cc);

            var cred = new TokenCredentials(authResult.AccessToken);
            _adfClient = new DataFactoryManagementClient(cred) { SubscriptionId = GetSetting("AZURE_SUBSCRIPTION_ID") };
        }

        public async Task<string> TriggerPipeline(string pipelineName, IDictionary<string, object> parameters)
        {
            await InitialiseClient();
            var response = await _adfClient.Pipelines.CreateRunWithHttpMessagesAsync(_rgName, _adfName, pipelineName, parameters: parameters);
            return response.Body.RunId;
        }

        public async Task<List<PipelineResource>> GetPipelines()
        {
            await InitialiseClient();

            var page = await _adfClient.Pipelines.ListByFactoryAsync(_rgName, _adfName);
            var pipelines = page.ToList();

            while (!string.IsNullOrWhiteSpace(page.NextPageLink))
            {
                page = await _adfClient.Pipelines.ListByFactoryNextAsync(page.NextPageLink);
                pipelines.AddRange(page.ToList());
            }

            return pipelines;
        }

        public async Task<List<ActivityRun>> GetActivityRuns(string pipelineRunId)
        {
            await InitialiseClient();

            var filter = new RunFilterParameters(DateTime.MinValue, DateTime.UtcNow);
            var arqr = await _adfClient.ActivityRuns.QueryByPipelineRunAsync(_rgName, _adfName, pipelineRunId, filter);
            var activityRuns = arqr.Value.ToList();

            while (!string.IsNullOrWhiteSpace(arqr.ContinuationToken))
            {
                filter.ContinuationToken = arqr.ContinuationToken;
                arqr = await _adfClient.ActivityRuns.QueryByPipelineRunAsync(_rgName, _adfName, pipelineRunId, filter);
                activityRuns.AddRange(arqr.Value);
            }

            return activityRuns;
        }
        public virtual void TearDown()
        {
            _adfClient?.Dispose();
        }

        public async Task<string> GetRunStatus(string pipelineRunId)
        {
            await InitialiseClient();
            var run = await _adfClient.PipelineRuns.GetAsync(_rgName, _adfName, pipelineRunId);
            return run.Status;
        }
        public async Task<string> GetRunStatus(string pipelineRunId, string adfName)
        {
            await InitialiseClient();
            var run = await _adfClient.PipelineRuns.GetAsync(_rgName, adfName, pipelineRunId);
            return run.Status;
        }

        public async Task<bool> IsInProgress(string pipelineRunId)
        {
            await InitialiseClient();
            var status = await GetRunStatus(pipelineRunId);
            return status == "Queued" || status == "InProgress" || status == "Cancelling";
        }
        public async Task<bool> IsInProgress(string pipelineRunId, string adfName)
        {
            await InitialiseClient();
            var status = await GetRunStatus(pipelineRunId, adfName);
            return status == "Queued" || status == "InProgress" || status == "Cancelling";
        }

        public async Task<bool> IsQueued(string pipelineRunId)
        {
            await InitialiseClient();
            var status = await GetRunStatus(pipelineRunId);
            return status == "Queued";
        }

        public async Task<bool> IsCancelling(string pipelineRunId)
        {
            await InitialiseClient();
            var status = await GetRunStatus(pipelineRunId);
            return status == "Cancelling" || status == "Canceling"; //microsoft typo
        }

        public async Task<bool> IsCancelling(string pipelineRunId, string adfName)
        {
            await InitialiseClient();
            var status = await GetRunStatus(pipelineRunId, adfName);
            return status == "Cancelling" || status == "Canceling"; //microsoft typo
        }

        public async Task<string> CancelRunningPipeline(string pipelineRunId, bool recurseCancel = true)
        {
            await InitialiseClient();
            if (await IsInProgress(pipelineRunId))
            {
                _adfClient.PipelineRuns.Cancel(_rgName, _adfName, pipelineRunId, recurseCancel);

                while (await IsCancelling(pipelineRunId))
                    Thread.Sleep(2000);
            }
            else
            {
                throw new Exception("Pipeline is not in a state that can be cancelled.");
            }

            string status = await GetRunStatus(pipelineRunId);
            return status;
        }

        public async Task<string> CancelRunningPipeline(string pipelineRunId, string adfName, bool recurseCancel = true)
        {
            await InitialiseClient();
            if (await IsInProgress(pipelineRunId, adfName))
            {
                _adfClient.PipelineRuns.Cancel(_rgName, adfName, pipelineRunId, recurseCancel);

                while (await IsCancelling(pipelineRunId, adfName))
                    Thread.Sleep(2000);
            }
            else
            {
                throw new Exception("Pipeline is not in a state that can be cancelled.");
            }

            string status = await GetRunStatus(pipelineRunId, adfName);
            return status;
        }

        public DataFactoryHelper()
        {
            _adfName = GetSetting("DataFactoryName");
            _rgName = GetSetting("DataFactoryResourceGroup");
        }
    }
}
