CREATE PROCEDURE [procfwk].[ResetExecution]
AS
BEGIN 
	
	--capture any pipelines that may have been cancelled
	INSERT INTO [procfwk].[ExecutionLog]
		(
		[LocalExecutionId],
		[StageId],
		[PipelineId],
		[PipelineName],
		[StartDateTime],
		[PipelineStatus],
		[EndDateTime]
		)
	SELECT
		[LocalExecutionId],
		[StageId],
		[PipelineId],
		[PipelineName],
		[StartDateTime],
		'Cancelled', --assumption that this is what happened
		[EndDateTime]
	FROM
		[procfwk].[CurrentExecution]
	WHERE
		--these are predicted states so aren't considered cancellations
		[PipelineStatus] NOT IN
			(
			'Success',
			'Failed',
			'Blocked'
			)
		
	--reset status ready for next attempt
	UPDATE
		[procfwk].[CurrentExecution]
	SET
		[StartDateTime] = NULL,
		[EndDateTime] = NULL,
		[PipelineStatus] = NULL,
		[LastStatusCheckDateTime] = NULL,
		[AdfPipelineRunId] = NULL,
		[PipelineParamsUsed] = NULL,
		[IsBlocked] = 0
	WHERE
		ISNULL([PipelineStatus],'') <> 'Success'
		OR [IsBlocked] = 1
	
	--return current execution id
	SELECT DISTINCT
		[LocalExecutionId] AS ExecutionId
	FROM
		[procfwk].[CurrentExecution]

END