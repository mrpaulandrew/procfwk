
CREATE   PROCEDURE procfwk.SetLogPipelineFailed
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
		[PipelineStatus] = 'Failed',
		[EndDateTime] = GETDATE()
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId

END
