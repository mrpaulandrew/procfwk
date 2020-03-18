CREATE PROCEDURE [procfwk].[SetLogPipelineUnknown]
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
		[PipelineStatus] = 'Unknown'
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId

END