CREATE PROCEDURE procfwk.SetLogPipelineSuccess
	(
	@ExecutionId UNIQUEIDENTIFIER,
	@StageId INT,
	@PipelineId INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE
		[procfwk].[CurrentExecution]
	SET
		[PipelineStatus] = 'Success',
		[EndDateTime] = GETUTCDATE()
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId
END;
