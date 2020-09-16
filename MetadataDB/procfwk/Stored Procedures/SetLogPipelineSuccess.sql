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
		--case for clean up runs
		[EndDateTime] = CASE WHEN [EndDateTime] IS NULL THEN GETUTCDATE() ELSE [EndDateTime] END,
		[PipelineStatus] = 'Success'
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId
END;
