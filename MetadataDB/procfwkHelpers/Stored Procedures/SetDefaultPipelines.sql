CREATE PROCEDURE [procfwkHelpers].[SetDefaultPipelines]
AS
BEGIN
	DECLARE @Pipelines TABLE
		(
		[OrchestratorId] [INT] NOT NULL,
		[StageId] [INT] NOT NULL,
		[PipelineName] [NVARCHAR](200) NOT NULL,
		[LogicalPredecessorId] [INT] NULL,
		[Enabled] [BIT] NOT NULL
		)

	INSERT @Pipelines
		(
		[OrchestratorId],
		[StageId],
		[PipelineName], 
		[LogicalPredecessorId],
		[Enabled]
		) 
	VALUES 
		(1,1	,'Wait 1'				,NULL		,1),
		(1,1	,'Wait 2'				,NULL		,1),
		(1,1	,'Intentional Error'	,NULL		,1),
		(1,1	,'Wait 3'				,NULL		,1),
		(1,2	,'Wait 4'				,NULL		,1),
		(1,2	,'Wait 5'				,1			,1),
		(1,2	,'Wait 6'				,1			,1),
		(1,2	,'Wait 7'				,NULL		,1),
		(1,3	,'Wait 8'				,1			,1),
		(1,3	,'Wait 9'				,6			,1),
		(1,4	,'Wait 10'				,9			,1),
		--speed
		(1,5	,'Wait 1'				,NULL		,0),
		(1,5	,'Wait 2'				,NULL		,0),
		(1,5	,'Wait 3'				,NULL		,0),
		(1,5	,'Wait 4'				,NULL		,0),
		--synapse
		(5,1	,'Wait 1'				,NULL		,1),
		(5,1	,'Wait 2'				,NULL		,1),
		(5,1	,'Wait 3'				,NULL		,1),
		(5,1	,'Wait 4'				,NULL		,1);

	MERGE INTO [procfwk].[Pipelines] AS tgt
	USING 
		@Pipelines AS src
			ON tgt.[OrchestratorId] = src.[OrchestratorId]
				AND tgt.[PipelineName] = src.[PipelineName]
				AND tgt.[StageId] = src.[StageId]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[LogicalPredecessorId] = src.[LogicalPredecessorId],
			tgt.[Enabled] = src.[Enabled]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[OrchestratorId],
			[StageId],
			[PipelineName], 
			[LogicalPredecessorId],
			[Enabled]
			)
		VALUES
			(
			src.[OrchestratorId],
			src.[StageId],
			src.[PipelineName], 
			src.[LogicalPredecessorId],
			src.[Enabled]
			)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;	
END;