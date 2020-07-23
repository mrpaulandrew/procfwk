CREATE VIEW [procfwkReporting].[WorkerParallelismOverTime]
AS

WITH numbers AS
	(
	SELECT TOP 500
		ROW_NUMBER() OVER (ORDER BY s1.[object_id]) - 1 AS 'Number'
	FROM 
		sys.all_columns AS s1
		CROSS JOIN sys.all_columns AS s2
	),
	executionBoundaries AS
	(
	SELECT
		[LocalExecutionId],
		CAST(CONVERT(VARCHAR(16), MIN([StartDateTime]), 120) AS DATETIME)  AS 'ExecutionStart',
		CAST(CONVERT(VARCHAR(16), MAX([EndDateTime]), 120) AS DATETIME) AS 'ExecutionEnd'
	FROM
		[procfwk].[ExecutionLog]
	--WHERE
	--	[LocalExecutionId] = '2BB02783-2A2C-4970-9BEA-0543013BFD5E'
	GROUP BY
		[LocalExecutionId]
	),
	wallclockRunning AS
	(
	SELECT
		CAST(DATEADD(MINUTE, n.[Number], eB.[ExecutionStart]) AS DATE) AS 'WallclockDate',
		CAST(DATEADD(MINUTE, n.[Number], eB.[ExecutionStart]) AS TIME) AS 'WallclockTime',
		el.[LocalExecutionId],
		el.[PipelineId],
		el.[PipelineName],
		s.[StageName]
	FROM
		executionBoundaries eB
		CROSS JOIN numbers n
		INNER JOIN [procfwk].[ExecutionLog] eL
			ON eB.[LocalExecutionId] = eL.[LocalExecutionId]
				AND DATEADD(MINUTE, n.[Number], eB.[ExecutionStart]) 
					BETWEEN eL.[StartDateTime] AND eL.[EndDateTime]
		INNER JOIN [procfwk].[Stages] s
			ON eL.[StageId] = s.[StageId]
	)

SELECT
	[WallclockDate],
	[WallclockTime],
	[LocalExecutionId],
	[StageName],
	STRING_AGG(ISNULL([PipelineName],' '),', ') As 'PipelineName',
	COUNT([PipelineId]) AS 'WorkerCount'
FROM
	wallclockRunning
GROUP BY
	[WallclockDate],
	[WallclockTime],
	[LocalExecutionId],
	[StageName]
GO


