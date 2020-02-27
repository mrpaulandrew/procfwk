
CREATE   PROCEDURE procfwk.SetLogPipelineRunning
	(
	@ExecutionId UNIQUEIDENTIFIER,
	@StageId INT,
	@PipelineId INT
	)
AS

BEGIN

	UPDATE
		[procfwk].[CurrentExecution]
	SET
		[PipelineStatus] = 'Running'
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId

END
