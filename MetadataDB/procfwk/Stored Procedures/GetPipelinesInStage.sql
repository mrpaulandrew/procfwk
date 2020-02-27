CREATE   PROCEDURE procfwk.GetPipelinesInStage
	(
	@StageId INT
	)
AS

SET NOCOUNT ON;

BEGIN

	SELECT 
		[PipelineId], 
		[PipelineName] 
	FROM 
		[procfwk].[CurrentExecution]
	WHERE 
		[StageId] = @StageId
	ORDER BY
		[PipelineId] ASC

END