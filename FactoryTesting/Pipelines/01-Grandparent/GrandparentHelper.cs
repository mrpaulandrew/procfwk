using FactoryTesting.Helpers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Grandparent
{
    class GrandparentHelper : CoverageHelper<GrandparentHelper>
    {
        public async Task RunPipeline()
        {
            await RunPipeline("01-Grandparent");
        }

        public GrandparentHelper WithTenantId()
        {
            AddTenantId();
            return this;
        }

        public GrandparentHelper WithSubscriptionId()
        {
            AddSubscriptionId();
            return this;
        }

        public GrandparentHelper WithSPNInDatabase(string workerFactoryName)
        {
            AddWorkerSPNStoredInDatabase(workerFactoryName);
            return this;
        }

        public GrandparentHelper WithSPNInKeyVault(string workerFactoryName)
        {
            AddWorkerSPNStoredInKeyVault(workerFactoryName);
            return this;
        }

        public GrandparentHelper WithBasicMetadata()
        {
            AddBasicMetadata();
            return this;
        }

        public GrandparentHelper WithEmptyExecutionTables()
        {
            WithEmptyTable("procfwk.CurrentExecution");
            WithEmptyTable("procfwk.ExecutionLog");
            WithEmptyTable("procfwk.ErrorLog");

            return this;
        }

        public GrandparentHelper WithSimpleFailureHandling()
        {
            ExecuteNonQuery("UPDATE [procfwk].[Properties] SET [PropertyValue] = 'Simple' WHERE [PropertyName] = 'FailureHandling'");
            return this;
        }
        public GrandparentHelper WithOneWorkerPipelineEnabled()
        {
            ExecuteNonQuery("UPDATE [procfwk].[Pipelines] SET [Enabled] = 0 WHERE [PipelineId] > 1");
            return this;
        }

        public GrandparentHelper With300WorkerPipelinesEnabled()
        {
            ExecuteStoredProcedure("[procfwkTesting].[Add300WorkerPipelines]", null);

            return this;
        }
    }
}
