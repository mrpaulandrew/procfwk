CREATE PROCEDURE [procfwk].[SetLogActivityFailed]
	(
	@ExecutionId UNIQUEIDENTIFIER,
	@StageId INT,
	@PipelineId INT,
	@RunId UNIQUEIDENTIFIER = NULL
	)
AS

BEGIN
	
	DECLARE @ErrorDetail VARCHAR(500)

	--mark specific failure pipeline
	UPDATE
		[procfwk].[CurrentExecution]
	SET
		[PipelineStatus] = 'Failed'
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId

	--flag all downstream stages as blocked
	UPDATE
		[procfwk].[CurrentExecution]
	SET
		[PipelineStatus] = 'Blocked',
		[IsBlocked] = 1
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] > @StageId

	--persist failed pipeline records to long term log
	INSERT INTO [procfwk].[ExecutionLog]
		(
		[LocalExecutionId],
		[StageId],
		[PipelineId],
		[PipelineName],
		[StartDateTime],
		[PipelineStatus],
		[EndDateTime]
		)
	SELECT
		[LocalExecutionId],
		[StageId],
		[PipelineId],
		[PipelineName],
		[StartDateTime],
		[PipelineStatus],
		[EndDateTime]
	FROM
		[procfwk].[CurrentExecution]
	WHERE
		[PipelineStatus] = 'Failed'
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId

END