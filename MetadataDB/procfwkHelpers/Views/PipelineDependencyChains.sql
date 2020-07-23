CREATE VIEW [procfwkHelpers].[PipelineDependencyChains]
AS

SELECT 
	ps.[StageName] AS PredecessorStage,
	pp.[PipelineName] AS PredecessorPipeline,
	ds.[StageName] AS DependantStage,
	dp.[PipelineName] AS DependantPipeline
FROM 
	[procfwk].[PipelineDependencies]					pd --pipeline dependencies
	INNER JOIN [procfwk].[Pipelines]					pp --predecessor pipelines
		ON pd.[PipelineId] = pp.[PipelineId]
	INNER JOIN [procfwk].[Pipelines]					dp --dependant pipelines
		ON pd.[DependantPipelineId] = dp.[PipelineId]
	INNER JOIN [procfwk].[Stages]						ps --predecessor stage
		ON pp.[StageId] = ps.[StageId]
	INNER JOIN [procfwk].[Stages]						ds --dependant stage
		ON dp.[StageId] = ds.[StageId];