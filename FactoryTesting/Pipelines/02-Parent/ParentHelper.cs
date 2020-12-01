using FactoryTesting.Helpers;
using System;
using System.Data.SqlClient;
using System.Threading;
using System.Threading.Tasks;
using System.Xml;

namespace FactoryTesting.Pipelines.Parent
{
    class ParentHelper : CoverageHelper<ParentHelper>
    {
        public async Task RunPipeline()
        {
            await RunPipeline("02-Parent");
        }
        public async Task RunPipeline(int fakeDelayMilliseconds)
        {
            Thread.Sleep(fakeDelayMilliseconds);
            await RunPipeline("02-Parent");
        }

        public async Task CancelAnyWorkerPipeline()
        {
            await CancelRunningPipeline(GetWorkerRunId(), GetSetting("WorkersDataFactoryName"));
        }
        public async Task CancelIntentionalErrorWorkerPipeline()
        {
            await CancelRunningPipeline(GetWorkerRunId("Intentional Error"), GetSetting("WorkersDataFactoryName"));
        }

        public virtual Task RunAsync()
        {
            return Task.CompletedTask;
        }
        public ParentHelper WithTenantAndSubscriptionIds()
        {
            AddTenantAndSubscription();
            return this;
        }
        public ParentHelper WithSPNInDatabase(string workerFactoryName)
        {
            AddWorkerSPNStoredInDatabase(workerFactoryName);
            return this;
        }

        public ParentHelper WithSPNInKeyVault(string workerFactoryName)
        {
            AddWorkerSPNStoredInKeyVault(workerFactoryName);
            return this;
        }

        public ParentHelper WithBasicMetadata()
        {
            AddBasicMetadata();
            return this;
        }

        public ParentHelper WithEmptyExecutionTables()
        {
            WithEmptyTable("procfwk.CurrentExecution");
            WithEmptyTable("procfwk.ExecutionLog");
            WithEmptyTable("procfwk.ErrorLog");

            return this;
        }

        public ParentHelper WithRunningPipelineStatusInPlaceOf(string statusToOveride)
        {
            SetFalsePipelineStatus("Running", "PipelineStatus", statusToOveride);
            return this;
        }

        public ParentHelper WithSimulatedError()
        {
            SimulateError(true);
            return this;
        }

        public ParentHelper WithoutSimulatedError()
        {
            SimulateError(false);
            return this;
        }

        public ParentHelper WithBatchesDisabled()
        {
            EnableDisableMetadata("Batches", false);
            return this;
        }

        public ParentHelper WithStagesDisabled()
        {
            EnableDisableMetadata("Stages", false);
            return this;
        }

        public ParentHelper WithStagesEnabled()
        {
            EnableDisableMetadata("Stages", true);
            return this;
        }

        public ParentHelper WithOnlyStageOneEnabled()
        {
            EnableDisableMetadata("Stages", false, "StageId", "2");
            EnableDisableMetadata("Stages", false, "StageId", "3");
            EnableDisableMetadata("Stages", false, "StageId", "4");
            EnableDisableMetadata("Stages", false, "StageId", "5");
            return this;
        }

        public ParentHelper WithPipelinesDisabled()
        {
            EnableDisableMetadata("Pipelines", false);
            return this;
        }
        public ParentHelper WithPipelinesEnabled()
        {
            EnableDisableMetadata("Pipelines", true);
            return this;
        }
        public ParentHelper With2MinWaitsOnWorkers()
        {
            SetParameterValue("120", "ParameterName", "WaitTime");
            return this;
        }

        public ParentHelper WithBatchExecutionHandling()
        {
            ExecuteNonQuery(@$"UPDATE [procfwk].[Properties] 
SET [PropertyValue] = '1' 
WHERE [PropertyName] = 'UseExecutionBatches'");
            return this;
        }

        public ParentHelper WithoutBatchExecutionHandling()
        {
            ExecuteNonQuery(@$"UPDATE [procfwk].[Properties] 
SET [PropertyValue] = '0' 
WHERE [PropertyName] = 'UseExecutionBatches'");
            return this;
        }

        public ParentHelper WithFailureHandling(string mode)
        {
            ExecuteNonQuery(@$"UPDATE [procfwk].[Properties] 
SET [PropertyValue] = '{mode}' 
WHERE [PropertyName] = 'FailureHandling'");
            return this;
        }

        public ParentHelper WithCancelledWorkersBlock(bool mode)
        {
            string modeString = mode ? "1" : "0";
            ExecuteNonQuery(@$"UPDATE [procfwk].[Properties] 
SET [PropertyValue] = '{modeString}' 
WHERE [PropertyName] = 'CancelledWorkerResultBlocks'");
            return this;
        }
        public ParentHelper WithOverideRestart(bool mode)
        {
            string modeString = mode ? "1" : "0";
            ExecuteNonQuery(@$"UPDATE [procfwk].[Properties] 
SET [PropertyValue] = '{modeString}' 
WHERE [PropertyName] = 'OverideRestart'");
            return this;
        }

        public ParentHelper WithoutPrecursorObject()
        {
            ExecuteNonQuery(@$"UPDATE [procfwk].[Properties] 
SET [PropertyValue] = '[dbo].[none]' 
WHERE [PropertyName] = 'ExecutionPrecursorProc'");
            return this;
        }

        public ParentHelper WithPrecursorObject()
        {
            ExecuteNonQuery(@$"UPDATE [procfwk].[Properties] 
SET [PropertyValue] = '[dbo].[ExampleCustomExecutionPrecursor]' 
WHERE [PropertyName] = 'ExecutionPrecursorProc'");
            return this;
        }
        public ParentHelper WithSingleExecutionStage()
        {
            ExecuteNonQuery("UPDATE [procfwk].[Pipelines] SET [StageId] = 1");
            return this;
        }

        public ParentHelper WithCustom()
        {
            ExecuteStoredProcedure("[dbo].[PaulTemp]", null);

            return this;
        }
        private ParentHelper SetFalsePipelineStatus(string falseStatus, string where, string equals)
        {
            ExecuteNonQuery($"UPDATE [procfwk].[CurrentExecution] SET [PipelineStatus] = '{falseStatus}' WHERE {where} = '{equals.Replace("'", "''")}'");
            return this;
        }

        private string GetWorkerRunId(string pipelineName = null)
        {
            string PipelineRunId;

            using (var cmd = new SqlCommand("procfwkTesting.GetRunIdWhenAvailable", _conn))
            {
                cmd.CommandTimeout = 600;
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                if (pipelineName != null) cmd.Parameters.Add(new SqlParameter("@PipelineName", pipelineName));

                using var reader = cmd.ExecuteReader();
                reader.Read();
                PipelineRunId = reader.GetString(0).ToLower();
            }
            return PipelineRunId;
        }

        private void EnableDisableMetadata(string table, bool state)
        {
            string paramValue = state ? "true" : "false";
            ExecuteNonQuery(@$"UPDATE [procfwk].[{table}] SET [Enabled] = '{paramValue}'");
        }

        private void EnableDisableMetadata(string table, bool state, string where, string equals)
        {
            string paramValue = state ? "true" : "false";
            ExecuteNonQuery(@$"UPDATE [procfwk].[{table}] SET [Enabled] = '{paramValue}' WHERE {where} = '{equals.Replace("'", "''")}'");
        }
        private void SetParameterValue(string value, string where, string equals)
        {
            string sqlStatement = @$"UPDATE [procfwk].[PipelineParameters] SET [ParameterValue] = '{value.Replace("'", "''")}' WHERE {where} = '{equals.Replace("'", "''")}'";
            ExecuteNonQuery(sqlStatement);
        }

        private void SimulateError(bool simulate)
        {
            string paramValue = simulate ? "true" : "false";
            ExecuteNonQuery(@$"UPDATE pp 
SET [ParameterValue] = '{paramValue}' 
FROM [procfwk].[PipelineParameters] pp 
  INNER JOIN  [procfwk].[Pipelines] p ON pp.[PipelineId] = p.[PipelineId] 
WHERE p.[PipelineName] = 'Intentional Error' AND pp.[ParameterName] = 'RaiseErrors'");
        }

        public override void TearDown()
        {
            base.TearDown();
        }
    }
}
