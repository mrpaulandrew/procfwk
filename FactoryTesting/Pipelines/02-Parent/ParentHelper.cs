using FactoryTesting.Helpers;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    class ParentHelper : CoverageHelper<ParentHelper>
    {
        public async Task RunPipeline()
        {
            await RunPipeline("02-Parent");
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

        private void EnableDisableMetadata(string table, bool state)
        {
            string paramValue = state ? "true" : "false";
            ExecuteNonQuery(@$"UPDATE [procfwk].[{table}] SET [Enabled] = '{paramValue}'");
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

        public ParentHelper WithFailureHandling(string mode)
        {
            ExecuteNonQuery(@$"UPDATE [procfwk].[Properties] 
SET [PropertyValue] = '{mode}' 
WHERE [PropertyName] = 'FailureHandling'");
            return this;
        }
        public ParentHelper InsertNewPipelineParameters()
        {
            ExecuteNonQuery(@"INSERT INTO [procfwk].[PipelineParameters] ([PipelineId],[ParameterName],[ParameterValue])
VALUES 
	(1, 'WaitTime', '3'),
	(2, 'WaitTime', '6'),
	(6, 'WaitTime', '9'),
	(4, 'WaitTime', '5'),
	(5, 'WaitTime', '2'),
	(3, 'RaiseErrors', 'false'),
	(3, 'WaitTime', '10'),
	(7, 'WaitTime', '3'),
	(8, 'WaitTime', '5'),
	(9, 'WaitTime', '7'),
	(11, 'WaitTime', '10')");

            return this;
        }

        public ParentHelper WithSingleExecutionStage()
        {
            ExecuteNonQuery("UPDATE [procfwk].[Pipelines] SET [StageId] = 1");
            return this;
        }

        public ParentHelper ResetPipelineStages()
        {
            ExecuteNonQuery(@"UPDATE
	[procfwk].[Pipelines]
SET
	[StageId] =
		CASE [PipelineId]
			WHEN 1 THEN 1
			WHEN 2 THEN 1
			WHEN 3 THEN 1
			WHEN 4 THEN 1
			WHEN 5 THEN 2
			WHEN 6 THEN 2
			WHEN 7 THEN 2
			WHEN 8 THEN 2
			WHEN 9 THEN 3
			WHEN 10 THEN 3
			WHEN 11 THEN 4
			ELSE 1
		END");

            return this;
        }

        public override void TearDown()
        {
            SimulateError(false);  // ensure default behaviour is to *not* simulate errors
            base.TearDown();
        }
    }
}
