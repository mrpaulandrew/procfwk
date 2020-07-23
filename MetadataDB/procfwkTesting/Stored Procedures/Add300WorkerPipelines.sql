CREATE PROCEDURE [procfwkTesting].[Add300WorkerPipelines]
AS
BEGIN

	--clear the decks from dev metadata
	DELETE FROM [procfwk].[PipelineDependencies];
	DBCC CHECKIDENT ('[procfwk].[PipelineDependencies]', RESEED, 0);

	DELETE FROM [procfwk].[PipelineAlertLink];
	DBCC CHECKIDENT ('[procfwk].[PipelineAlertLink]', RESEED, 0);

	DELETE FROM [procfwk].[Recipients];
	DBCC CHECKIDENT ('[procfwk].[Recipients]', RESEED, 0);

	DELETE FROM [procfwk].[PipelineAuthLink];
	DBCC CHECKIDENT ('[procfwk].[PipelineAuthLink]', RESEED, 0);

	DELETE FROM [dbo].[ServicePrincipals];
	DBCC CHECKIDENT ('[dbo].[ServicePrincipals]', RESEED, 0);

	DELETE FROM [procfwk].[PipelineParameters];
	DBCC CHECKIDENT ('[procfwk].[PipelineParameters]', RESEED, 0);

	DELETE FROM [procfwk].[Pipelines];
	DBCC CHECKIDENT ('[procfwk].[Pipelines]', RESEED, 0);

	--get data factory id
	DECLARE @ADFId INT
	
	SELECT 
		@ADFId = [DataFactoryId] 
	FROM 
		[procfwk].[DataFactorys] 
	WHERE 
		[DataFactoryName] = 'WorkersFactory';

	--insert 300 pipelines
	;WITH cte AS
		(
		SELECT TOP 300
			ROW_NUMBER() OVER (ORDER BY s1.[object_id]) AS 'Number'
		FROM 
			sys.all_columns AS s1
			CROSS JOIN sys.all_columns AS s2
		)
	INSERT INTO [procfwk].[Pipelines]
		(
		[DataFactoryId],
		[StageId],
		[PipelineName],
		[LogicalPredecessorId],
		[Enabled]
		)
	SELECT
		@ADFId,
		CASE
			WHEN [Number] <= 100 THEN 1
			WHEN [Number] > 100 AND  [Number] <= 200 THEN 2
			WHEN [Number] > 200 AND  [Number] <= 300 THEN 3
		END,
		'Wait ' + CAST([Number] AS VARCHAR),
		NULL,
		1
	FROM
		cte;

	--disable other execution stages if exist
	UPDATE [procfwk].[Stages] SET [Enabled] = 0 WHERE [StageId] > 3;

	--insert 300 pipeline parameters
	INSERT INTO [procfwk].[PipelineParameters]	
		(
		[PipelineId],
		[ParameterName],
		[ParameterValue]
		)
	SELECT
		[PipelineId],
		'WaitTime',
		LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)),2)
	FROM
		[procfwk].[Pipelines];
END;