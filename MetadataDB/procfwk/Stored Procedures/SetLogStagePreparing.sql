
CREATE   PROCEDURE [procfwk].[SetLogStagePreparing]
	(
	@ExecutionId UNIQUEIDENTIFIER,
	@StageId INT
	)
AS

BEGIN
	
	UPDATE
		[procfwk].[CurrentExecution]
	SET
		[PipelineStatus] = 'Preparing'
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [StartDateTime] IS NULL

END
