
CREATE   PROCEDURE procfwk.SetLogPipelineSuccess
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
		[PipelineStatus] = 'Success',
		[EndDateTime] = GETDATE()
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId

END
