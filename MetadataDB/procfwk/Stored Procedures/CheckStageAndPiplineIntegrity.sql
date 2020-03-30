CREATE PROCEDURE [procfwk].[CheckStageAndPiplineIntegrity]
AS

BEGIN

	SELECT
		adf.[ResourceGroupName],
		adf.[DataFactoryName],	
		base.[StageId],
		baseStage.[StageName],
		base.[PipelineId],
		base.[PipelineName],
		base.[Enabled],
		preds.[StageId] 'SuccessorStageId',
		predsStage.[StageName] AS 'SuccessorStage',
		preds.[PipelineId] AS 'SuccessorId',
		preds.[PipelineName] AS 'SuccessorName',
		CASE
			WHEN preds.[StageId] > base.[StageId] +1 THEN 'Successor pipeline could be moved to an earlier stage.'
			WHEN preds.[StageId] = base.[StageId] THEN 'Dependency issue, predeccessor pipeline is currently running in the same stage as successor.'
			WHEN preds.[PipelineId] IS NOT NULL AND base.[Enabled] = 0 THEN 'Disabled pipeline has downstream successors.'
			WHEN preds.[PipelineId] IS NOT NULL AND baseStage.[Enabled] = 0 THEN 'Disabled stage has downstream successors.'
			ELSE NULL
		END AS 'Information'
	FROM 
		--get base pipeline details
		[procfwk].[Pipelines] base
		INNER JOIN [procfwk].[DataFactorys] adf
			ON base.[DataFactoryId] = adf.[DataFactoryId]
		INNER JOIN [procfwk].[Stages] baseStage
			ON base.[StageId] = baseStage.[StageId]	
		--get successor details
		LEFT OUTER JOIN [procfwk].[Pipelines] preds
			ON base.[PipelineId] = preds.[LogicalPredecessorId]
		LEFT OUTER JOIN [procfwk].[Stages] predsStage
			ON preds.[StageId] = predsStage.[StageId]

END

