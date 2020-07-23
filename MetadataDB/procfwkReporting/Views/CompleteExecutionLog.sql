CREATE VIEW [procfwkReporting].[CompleteExecutionLog]
AS

SELECT
	[LogId],
	[LocalExecutionId],
	[StageId],
	[PipelineId],
	[CallingDataFactoryName],
	[ResourceGroupName],
	[DataFactoryName],
	[PipelineName],
	[StartDateTime],
	[PipelineStatus],
	[EndDateTime],
	DATEDIFF(MINUTE, [StartDateTime], [EndDateTime]) 'RunDurationMinutes'
FROM 
	[procfwk].[ExecutionLog]