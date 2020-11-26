CREATE PROCEDURE [procfwk].[SetLogPipelineUnknown]
	(
	@ExecutionId UNIQUEIDENTIFIER,
	@StageId INT,
	@PipelineId INT,
	@CleanUpRun BIT = 0
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ErrorDetail VARCHAR(500);

	--mark specific failure pipeline
	UPDATE
		[procfwk].[CurrentExecution]
	SET
		[PipelineStatus] = 'Unknown'
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId

	--no need to block and log if done during a clean up cycle
	IF @CleanUpRun = 1 RETURN 0;

	--persist unknown pipeline records to long term log
	INSERT INTO [procfwk].[ExecutionLog]
		(
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
		[PipelineRunId],
		[PipelineParamsUsed]
		)
	SELECT
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
		[PipelineRunId],
		[PipelineParamsUsed]
	FROM
		[procfwk].[CurrentExecution]
	WHERE
		[PipelineStatus] = 'Unknown'
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId;

	--block down stream stages?
	IF ([procfwk].[GetPropertyValueInternal]('UnknownWorkerResultBlocks')) = 1
	BEGIN	
		--decide how to proceed with error/failure depending on framework property configuration
		IF ([procfwk].[GetPropertyValueInternal]('FailureHandling')) = 'None'
			BEGIN
				--do nothing allow processing to carry on regardless
				RETURN 0;
			END;
		
		ELSE IF ([procfwk].[GetPropertyValueInternal]('FailureHandling')) = 'Simple'
			BEGIN
				--flag all downstream stages as blocked
				UPDATE
					[procfwk].[CurrentExecution]
				SET
					[PipelineStatus] = 'Blocked',
					[IsBlocked] = 1
				WHERE
					[LocalExecutionId] = @ExecutionId
					AND [StageId] > @StageId

				UPDATE
					[procfwk].[BatchExecution]
				SET
					[BatchStatus] = 'Stopping'
				WHERE
					[ExecutionId] = @ExecutionId
					AND [BatchStatus] = 'Running';

				SET @ErrorDetail = 'Pipeline execution has an unknown status. Blocking downstream stages as a precaution.'

				RAISERROR(@ErrorDetail,16,1);
				RETURN 0;
			END;
		ELSE IF ([procfwk].[GetPropertyValueInternal]('FailureHandling')) = 'DependencyChain'
			BEGIN
				EXEC [procfwk].[SetExecutionBlockDependants]
					@ExecutionId = @ExecutionId,
					@PipelineId = @PipelineId
			END;
		ELSE
			BEGIN
				RAISERROR('Unknown failure handling state.',16,1);
				RETURN 0;
			END;
	END;
END;