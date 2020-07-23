CREATE VIEW [procfwkReporting].[CompleteExecutionErrorLog]
AS

SELECT
	exeLog.[LogId] AS 'ExecutionLogId',
	errLog.[LogId] AS 'ErrorLogId',
	exeLog.[LocalExecutionId],
	exeLog.[StartDateTime] AS 'ProcessingDateTime',
	exeLog.[CallingDataFactoryName],
	exeLog.[DataFactoryName] AS 'WorkerDataFactory',
	exeLog.[PipelineName] AS 'WorkerPipelineName',
	exeLog.[PipelineStatus],
	errLog.[ActivityRunId],
	errLog.[ActivityName],
	errLog.[ActivityType],
	errLog.[ErrorCode],
	errLog.[ErrorType],
	errLog.[ErrorMessage]
FROM
	[procfwk].[ExecutionLog] exeLog
	INNER JOIN [procfwk].[ErrorLog] errLog
		ON exeLog.[LocalExecutionId] = errLog.[LocalExecutionId]
			AND exeLog.[AdfPipelineRunId] = errLog.[AdfPipelineRunId]
	INNER JOIN [procfwk].[Stages] stgs
		ON exeLog.[StageId] = stgs.[StageId]
;