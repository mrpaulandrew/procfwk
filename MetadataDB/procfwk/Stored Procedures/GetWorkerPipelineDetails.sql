CREATE PROCEDURE [procfwk].[GetWorkerPipelineDetails]
	(
	@ExecutionId UNIQUEIDENTIFIER,
	@StageId INT,
	@PipelineId INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		[PipelineName],
		[OrchestratorName],
		[OrchestratorType],
		[ResourceGroupName]
	FROM 
		[procfwk].[CurrentExecution]
	WHERE 
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId;
END;