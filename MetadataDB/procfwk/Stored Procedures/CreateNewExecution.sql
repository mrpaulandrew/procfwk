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
		[PipelineName]
		)
	SELECT
		@LocalExecutionId,
		p.[StageId],
		p.[PipelineId],
		p.[PipelineName]
	FROM
		[procfwk].[PipelineProcesses] p
		INNER JOIN [procfwk].[ProcessingStageDetails] s
			ON p.[StageId] = s.[StageId]
	WHERE
		p.[Enabled] = 1
		AND s.[Enabled] = 1

	SELECT
		@LocalExecutionId AS 'ExecutionId'

END
