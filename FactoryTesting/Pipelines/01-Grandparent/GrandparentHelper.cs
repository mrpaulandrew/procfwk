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

        public GrandparentHelper WithTenantAndSubscriptionIds()
        {
            AddTenantAndSubscription();
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

        public GrandparentHelper WithBatchExecutionHandling()
        {
            ExecuteNonQuery(@$"UPDATE [procfwk].[Properties] 
SET [PropertyValue] = '1' 
WHERE [PropertyName] = 'UseExecutionBatches'");
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

        public GrandparentHelper With20BatchesFor1000WorkersEnabled()
        {
            ExecuteStoredProcedure("[procfwkTesting].[Add20BatchesFor1000Workers]", null);

            return this;
        }

        public GrandparentHelper WithCustom()
        {
            ExecuteStoredProcedure("[dbo].[PaulTemp]", null);

            return this;
        }

        public GrandparentHelper With300WorkerPipelineBatches()
        {
            ExecuteStoredProcedure("[procfwkTesting].[Add300WorkerPipelineBatches]", null);

            return this;
        }
    }
}
