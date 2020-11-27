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

	--persist failed pipeline records to long term log
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
		[LocalExecutionId] = @ExecutionId
		AND [PipelineStatus] = @CallingActivity + 'Error'
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId
	
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
				AND [StageId] > @StageId;

			--update batch if applicable
			IF ([procfwk].[GetPropertyValueInternal]('UseExecutionBatches')) = '1'
				BEGIN
					UPDATE
						[procfwk].[BatchExecution]
					SET
						[BatchStatus] = 'Stopping' --special case when its an activity failure to call stop ready for restart
					WHERE
						[ExecutionId] = @ExecutionId
						AND [BatchStatus] = 'Running';
				END;			
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