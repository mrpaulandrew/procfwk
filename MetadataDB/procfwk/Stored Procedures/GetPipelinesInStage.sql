CREATE PROCEDURE procfwk.GetPipelinesInStage
	(
	@StageId INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		[PipelineId], 
		[PipelineName],
		[DataFactoryName],
		[ResourceGroupName]
	FROM 
		[procfwk].[CurrentExecution]
	WHERE 
		[StageId] = @StageId
		AND ISNULL([PipelineStatus],'') <> 'Success'
	ORDER BY
		[PipelineId] ASC
END;