CREATE VIEW [procfwkReporting].[LastExecution]
AS

WITH maxLog AS
	(
	SELECT
		MAX([LogId]) AS 'MaxLogId'
	FROM
		[procfwk].[ExecutionLog]
	),
	lastExecutionId AS
	(
	SELECT
		[LocalExecutionId]
	FROM
		[procfwk].[ExecutionLog] el1
		INNER JOIN maxLog
			ON maxLog.[MaxLogId] = el1.[LogId]
	)
SELECT
	el2.[LogId],
	el2.[StageId],
	el2.[PipelineId],
	el2.[PipelineName],
	el2.[StartDateTime],
	el2.[PipelineStatus],
	el2.[EndDateTime],
	DATEDIFF(MINUTE, el2.[StartDateTime], el2.[EndDateTime]) AS RunDurationMinutes
FROM 
	[procfwk].[ExecutionLog] el2
	INNER JOIN lastExecutionId
		ON el2.[LocalExecutionId] = lastExecutionId.[LocalExecutionId]
WHERE
	el2.[EndDateTime] IS NOT NULL;