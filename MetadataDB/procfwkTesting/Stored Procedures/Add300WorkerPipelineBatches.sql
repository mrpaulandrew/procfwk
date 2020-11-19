CREATE PROCEDURE [procfwkTesting].[Add300WorkerPipelineBatches]
AS
BEGIN
	SET NOCOUNT ON;

	--clear default metadata
	DELETE FROM [procfwk].[BatchStageLink];
	DELETE FROM [procfwk].[Batches];

	--add batch details
	;WITH sourceData AS
		(
		SELECT
			'0to300' AS BatchName, 
			'The first 300.' AS BatchDescription,
			1 AS [Enabled]
		UNION SELECT
			'301to600',
			'The second 300.',
			1	
		)
	MERGE INTO [procfwk].[Batches] AS tgt
	USING 
		sourceData AS src
			ON tgt.[BatchName] = src.[BatchName]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[BatchDescription] = src.[BatchDescription],
			tgt.[Enabled] = src.[Enabled]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[BatchName],
			[BatchDescription],
			[Enabled]
			)
		VALUES
			(
			src.[BatchName],
			src.[BatchDescription],
			src.[Enabled]
			)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;	
	
	--link batches to stages
	INSERT INTO [procfwk].[BatchStageLink]
		(
		[BatchId],
		[StageId]
		)
	SELECT
		b.[BatchId],
		s.[StageId]
	FROM
		[procfwk].[Batches] b
		INNER JOIN [procfwk].[Stages] s
			ON s.[Enabled] = 1;
END;
