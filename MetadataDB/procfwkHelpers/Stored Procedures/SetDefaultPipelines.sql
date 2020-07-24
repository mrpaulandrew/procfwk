CREATE PROCEDURE [procfwkHelpers].[SetDefaultPipelines]
AS
BEGIN
	DECLARE @Pipelines TABLE
		(
		[DataFactoryId] [INT] NOT NULL,
		[StageId] [INT] NOT NULL,
		[PipelineName] [NVARCHAR](200) NOT NULL,
		[LogicalPredecessorId] [INT] NULL,
		[Enabled] [BIT] NOT NULL
		)

	INSERT @Pipelines
		(
		[DataFactoryId],
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
		(1,4	,'Wait 10'				,9			,1);

	MERGE INTO [procfwk].[Pipelines] AS tgt
	USING 
		@Pipelines AS src
			ON tgt.[PipelineName] = src.[PipelineName]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[DataFactoryId] = src.[DataFactoryId],
			tgt.[StageId] = src.[StageId],
			tgt.[LogicalPredecessorId] = src.[LogicalPredecessorId],
			tgt.[Enabled] = src.[Enabled]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[DataFactoryId],
			[StageId],
			[PipelineName], 
			[LogicalPredecessorId],
			[Enabled]
			)
		VALUES
			(
			src.[DataFactoryId],
			src.[StageId],
			src.[PipelineName], 
			src.[LogicalPredecessorId],
			src.[Enabled]
			)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;	
END;