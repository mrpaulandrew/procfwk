CREATE PROCEDURE [procfwk].[SetLogActivityFailed]
	(
	@ExecutionId UNIQUEIDENTIFIER,
	@StageId INT,
	@PipelineId INT,
	@CallingActivity VARCHAR(255)
	)
AS

BEGIN
	SET NOCOUNT ON;
	
	--mark specific failure pipeline
	UPDATE
		[procfwk].[CurrentExecution]
	SET
		[PipelineStatus] = @CallingActivity + 'Error'
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId

	--flag all downstream stages as blocked
	UPDATE
		[procfwk].[CurrentExecution]
	SET
		[PipelineStatus] = 'Blocked',
		[IsBlocked] = 1
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] > @StageId

	--persist failed pipeline records to long term log
	INSERT INTO [procfwk].[ExecutionLog]
		(
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
		[AdfPipelineRunId],
		[PipelineParamsUsed]
		)
	SELECT
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
		[AdfPipelineRunId],
		[PipelineParamsUsed]
	FROM
		[procfwk].[CurrentExecution]
	WHERE
		[PipelineStatus] = @CallingActivity + 'Error'
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId
END;