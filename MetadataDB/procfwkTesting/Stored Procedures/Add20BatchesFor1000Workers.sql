CREATE PROCEDURE [procfwkTesting].[Add20BatchesFor1000Workers]
AS
BEGIN
	SET NOCOUNT ON;

	--clear default metadata
	DELETE FROM [procfwk].[BatchStageLink];
	
	DELETE FROM [procfwk].[Batches];

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

	--get Orchestrator id
	DECLARE @OrcId INT
	
	SELECT 
		@OrcId = [OrchestratorId] 
	FROM 
		[procfwk].[Orchestrators] 
	WHERE 
		[OrchestratorName] = 'WorkersFactory'
		AND [OrchestratorType] = 'ADF';

	--tweak properties
	UPDATE
		[procfwk].[Properties]
	SET
		[PropertyValue] = '[dbo].[None]'
	WHERE
		[PropertyName] = 'ExecutionPrecursorProc';

	UPDATE
		[procfwk].[Properties]
	SET
		[PropertyValue] = '30'
	WHERE
		[PropertyName] = 'PipelineStatusCheckDuration';

	UPDATE
		[procfwk].[Properties]
	SET
		[PropertyValue] = '0'
	WHERE
		[PropertyName] = 'UseFrameworkEmailAlerting';

	UPDATE
		[procfwk].[Properties]
	SET
		[PropertyValue] = '1'
	WHERE
		[PropertyName] = 'UseExecutionBatches';

	--insert 200 pipelines
	;WITH cte AS
		(
		SELECT TOP 200
			ROW_NUMBER() OVER (ORDER BY s1.[object_id]) AS Number
		FROM 
			sys.all_columns AS s1
			CROSS JOIN sys.all_columns AS s2
		)
	INSERT INTO [procfwk].[Pipelines]
		(
		[OrchestratorId],
		[StageId],
		[PipelineName],
		[LogicalPredecessorId],
		[Enabled]
		)
	SELECT
		@OrcId,
		CASE
			WHEN [Number] <= 50 THEN 1
			WHEN [Number] > 50 AND  [Number] <= 100 THEN 2
			WHEN [Number] > 100 AND  [Number] <= 150 THEN 3
			WHEN [Number] > 150 AND  [Number] <= 200 THEN 4
		END,
		'Wait ' + CAST([Number] AS VARCHAR),
		NULL,
		1
	FROM
		cte;

	--disable other execution stages if exist
	UPDATE [procfwk].[Stages] SET [Enabled] = 1;
	UPDATE [procfwk].[Stages] SET [Enabled] = 0 WHERE [StageId] > 4;

	--insert 200 pipeline parameters
	INSERT INTO [procfwk].[PipelineParameters]	
		(
		[PipelineId],
		[ParameterName],
		[ParameterValue]
		)
	SELECT
		[PipelineId],
		'WaitTime',
		LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)),1)
	FROM
		[procfwk].[Pipelines];
	
	--insert batches
	;WITH batchNames AS
		(
		SELECT 'One' AS [Name]
		UNION SELECT 'Two'
		UNION SELECT 'Three'
		UNION SELECT 'Four'
		UNION SELECT 'Five'
		UNION SELECT 'Six'
		UNION SELECT 'Seven'
		UNION SELECT 'Eight'
		UNION SELECT 'Nine'
		UNION SELECT 'Ten'
		UNION SELECT 'Eleven'
		UNION SELECT 'Twelve'
		UNION SELECT 'Thirteen'
		UNION SELECT 'Fourteen'
		UNION SELECT 'Fifteen'
		UNION SELECT 'Sixteen'
		UNION SELECT 'Seventeen'
		UNION SELECT 'Eighteen'
		UNION SELECT 'Nineteen'
		UNION SELECT 'Twenty'
		)
	INSERT INTO [procfwk].[Batches]
		(
		[BatchName],
		[BatchDescription],
		[Enabled]
		)
	SELECT
		[Name],
		'1000 Workers Test',
		1
	FROM
		batchNames
	
	--allocation batches to stages evenly
	;WITH maxStages AS
		(
		SELECT 
			MAX([StageId]) AS Id
		FROM
			[procfwk].[Stages]
		WHERE
			[Enabled] = 1
		)
	INSERT INTO [procfwk].[BatchStageLink]
	SELECT  
		b.[BatchId],
		CASE
			WHEN (ROW_NUMBER() OVER (ORDER BY b.[BatchName] DESC) * 1) % maxStages.[Id] = 0 THEN maxStages.[Id] 
			ELSE (ROW_NUMBER() OVER (ORDER BY b.[BatchName] DESC) * 1) % maxStages.[Id] 
		END AS Stage
	FROM 
		[procfwk].[Batches] b
		CROSS JOIN maxStages;

	/*
	--generate the c# for the NUnit test:

	SELECT
	[BatchName],
	'private GrandparentHelper _helperBatch' + [BatchName] + ';',
    '_helperBatch' + [BatchName] + ' = new GrandparentHelper().WithParameter("BatchName", "' + [BatchName] + '");',
	'var batch' + [BatchName] + ' = _helperBatch' + [BatchName] + '.RunPipeline();',
	'batch' + [BatchName] + ',',
'[Test]' + CHAR(13) +
'public void Then' + [BatchName] + 'BatchPipelineOutcomeIsSucceeded()' + CHAR(13) +
'{' + CHAR(13) +
'    _helperBatch' + [BatchName] + '.RunOutcome.Should().Be("Succeeded");' + CHAR(13) +
'}'
FROM 
	[procfwk].[Batches]
	*/
END;