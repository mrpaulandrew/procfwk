CREATE PROCEDURE [procfwk].[UpdateExecutionLog]
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [procfwk].[ExecutionLog]
		(
		[LocalExecutionId],
		[StageId],
		[PipelineId],
		[CallingDataFactoryName],
		[ResourceGroupName],
		[DataFactoryName],
		[PipelineName],
		[StartDateTime],
		[PipelineStatus],
		[EndDateTime],
		[AdfPipelineRunId],
		[PipelineParamsUsed]
		)
	SELECT
		[LocalExecutionId],
		[StageId],
		[PipelineId],
		[CallingDataFactoryName],
		[ResourceGroupName],
		[DataFactoryName],
		[PipelineName],
		[StartDateTime],
		[PipelineStatus],
		[EndDateTime],
		[AdfPipelineRunId],
		[PipelineParamsUsed]
	FROM
		[procfwk].[CurrentExecution];

	TRUNCATE TABLE [procfwk].[CurrentExecution];
END;