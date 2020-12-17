CREATE PROCEDURE [procfwk].[ResetExecution]
	(
	@LocalExecutionId UNIQUEIDENTIFIER = NULL
	)
AS
BEGIN 
	SET NOCOUNT	ON;

	IF([procfwk].[GetPropertyValueInternal]('UseExecutionBatches')) = '0'
		BEGIN
			--capture any pipelines that might be in an unexpected state
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
				[EndDateTime]
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
				'Unknown',
				[EndDateTime]
			FROM
				[procfwk].[CurrentExecution]
			WHERE
				--these are predicted states
				[PipelineStatus] NOT IN
					(
					'Success',
					'Failed',
					'Blocked',
					'Cancelled'
					);
		
			--reset status ready for next attempt
			UPDATE
				[procfwk].[CurrentExecution]
			SET
				[StartDateTime] = NULL,
				[EndDateTime] = NULL,
				[PipelineStatus] = NULL,
				[LastStatusCheckDateTime] = NULL,
				[PipelineRunId] = NULL,
				[PipelineParamsUsed] = NULL,
				[IsBlocked] = 0
			WHERE
				ISNULL([PipelineStatus],'') <> 'Success'
				OR [IsBlocked] = 1;
	
			--return current execution id
			SELECT DISTINCT
				[LocalExecutionId] AS ExecutionId
			FROM
				[procfwk].[CurrentExecution];
		END
	ELSE IF ([procfwk].[GetPropertyValueInternal]('UseExecutionBatches')) = '1'
		BEGIN
			--capture any pipelines that might be in an unexpected state
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
				[EndDateTime]
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
				'Unknown',
				[EndDateTime]
			FROM
				[procfwk].[CurrentExecution]
			WHERE
				[LocalExecutionId] = @LocalExecutionId
				--these are predicted states
				AND [PipelineStatus] NOT IN
					(
					'Success',
					'Failed',
					'Blocked',
					'Cancelled'
					);
		
			--reset status ready for next attempt
			UPDATE
				[procfwk].[CurrentExecution]
			SET
				[StartDateTime] = NULL,
				[EndDateTime] = NULL,
				[PipelineStatus] = NULL,
				[LastStatusCheckDateTime] = NULL,
				[PipelineRunId] = NULL,
				[PipelineParamsUsed] = NULL,
				[IsBlocked] = 0
			WHERE
				[LocalExecutionId] = @LocalExecutionId
				AND ISNULL([PipelineStatus],'') <> 'Success'
				OR [IsBlocked] = 1;
				
			UPDATE
				[procfwk].[BatchExecution]
			SET
				[EndDateTime] = NULL,
				[BatchStatus] = 'Running'
			WHERE
				[ExecutionId] = @LocalExecutionId;

			SELECT 
				@LocalExecutionId AS ExecutionId
		END;
END;