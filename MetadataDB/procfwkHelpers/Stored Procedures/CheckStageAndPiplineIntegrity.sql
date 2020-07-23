CREATE PROCEDURE [procfwkHelpers].[CheckStageAndPiplineIntegrity]
AS

BEGIN

	DECLARE @TempCheckStageAndPiplineIntegrity TABLE
		(
		[ResourceGroupName] NVARCHAR(200) NOT NULL,
		[DataFactoryName] NVARCHAR(200) NOT NULL,
		[StageId] INT NOT NULL,
		[StageName] VARCHAR(225) NOT NULL,
		[PipelineId] INT NOT NULL,
		[PipelineName] NVARCHAR(200) NOT NULL,
		[Enabled] BIT NOT NULL,
		[SuccessorStageId] INT NULL,
		[SuccessorStage] VARCHAR(225) NULL,
		[SuccessorId] INT NULL,
		[SuccessorName] NVARCHAR(200) NULL,
		[Information] VARCHAR(92) NULL
		)	
	
	--get min execution stage
	;WITH firstStage AS
		(
		SELECT
			MIN([StageId]) AS firstStageId
		FROM
			[procfwk].[Stages]
		)
	--query metadata
	INSERT INTO @TempCheckStageAndPiplineIntegrity
	SELECT
		adf.[ResourceGroupName],
		adf.[DataFactoryName],	
		base.[StageId],
		baseStage.[StageName],
		base.[PipelineId],
		base.[PipelineName],
		base.[Enabled],
		preds.[StageId] AS SuccessorStageId,
		predsStage.[StageName] AS SuccessorStage,
		preds.[PipelineId] AS SuccessorId,
		preds.[PipelineName] AS SuccessorName,
		CASE
			WHEN preds.[StageId] > base.[StageId] +1 THEN 'Successor pipeline could be moved to an earlier stage.'
			WHEN preds.[StageId] = base.[StageId] THEN 'Dependency issue, predeccessor pipeline is currently running in the same stage as successor.'
			WHEN preds.[PipelineId] IS NOT NULL AND base.[Enabled] = 0 THEN 'Disabled pipeline has downstream successors.'
			WHEN preds.[PipelineId] IS NOT NULL AND baseStage.[Enabled] = 0 THEN 'Disabled stage has downstream successors.'
			WHEN base.[LogicalPredecessorId] IS NULL AND base.[StageId] <> firstStage.[firstStageId] THEN 'Pipeline could be moved to an earlier stage.'
			ELSE NULL
		END AS Information
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
		--other details for checking
		CROSS JOIN firstStage

	--provide outcome
	IF EXISTS
		(
		SELECT [Information] FROM @TempCheckStageAndPiplineIntegrity
		)
		BEGIN
			SELECT * FROM @TempCheckStageAndPiplineIntegrity
		END
	ELSE
		BEGIN
			PRINT 'No pipeline integrity issues to report. Nice work! :-)'
		END
END;

