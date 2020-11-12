CREATE PROCEDURE [procfwkHelpers].[SetDefaultBatchStageLink]
AS
BEGIN

	TRUNCATE TABLE [procfwk].[BatchStageLink]

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
		CROSS JOIN [procfwk].[Stages] s
	WHERE
		b.[BatchName] = 'Daily'

	UNION ALL

	SELECT
		b.[BatchId],
		s.[StageId]
	FROM
		[procfwk].[Batches] b
		CROSS JOIN [procfwk].[Stages] s
	WHERE
		b.[BatchName] = 'Hourly'

END;