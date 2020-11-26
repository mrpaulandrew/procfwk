CREATE VIEW [procfwkReporting].[CompleteExecutionLog]
AS

SELECT
	[LogId],
	[LocalExecutionId],
	[StageId],
	[PipelineId],
	[CallingOrchestratorName],
	[ResourceGroupName],
	[OrchestratorType],
	[OrchestratorName],
	[PipelineName],
	[StartDateTime],
	[PipelineStatus],
	[EndDateTime],
	DATEDIFF(MINUTE, [StartDateTime], [EndDateTime]) 'RunDurationMinutes'
FROM 
	[procfwk].[ExecutionLog]