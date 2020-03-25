CREATE   PROCEDURE [procfwk].[CreateNewExecution]
AS

SET NOCOUNT ON;

BEGIN

	DECLARE @LocalExecutionId UNIQUEIDENTIFIER = NEWID()

	TRUNCATE TABLE [procfwk].[CurrentExecution];

	INSERT INTO [procfwk].[CurrentExecution]
		(
		[LocalExecutionId],
		[StageId],
		[PipelineId],
		[ResourceGroupName],
		[DataFactoryName],
		[PipelineName]
		)
	SELECT
		@LocalExecutionId,
		p.[StageId],
		p.[PipelineId],
		d.[ResourceGroupName],
		d.[DataFactoryName],
		p.[PipelineName]
	FROM
		[procfwk].[PipelineProcesses] p
		INNER JOIN [procfwk].[ProcessingStageDetails] s
			ON p.[StageId] = s.[StageId]
		INNER JOIN [procfwk].[DataFactoryDetails] d
			ON p.[DataFactoryId] = d.[DataFactoryId]
	WHERE
		p.[Enabled] = 1
		AND s.[Enabled] = 1

	ALTER INDEX [IDX_GetPipelinesInStage] ON [procfwk].[CurrentExecution]
	REBUILD;

	SELECT
		@LocalExecutionId AS 'ExecutionId'

END
