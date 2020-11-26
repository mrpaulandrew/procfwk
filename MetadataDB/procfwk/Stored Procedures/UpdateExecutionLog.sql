CREATE PROCEDURE [procfwk].[UpdateExecutionLog]
	(
	@PerformErrorCheck BIT = 1,
	@ExecutionId UNIQUEIDENTIFIER = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @AllCount INT
	DECLARE @SuccessCount INT

	IF([procfwk].[GetPropertyValueInternal]('UseExecutionBatches')) = '0'
		BEGIN
			IF @PerformErrorCheck = 1
			BEGIN
				--Check current execution
				SELECT @AllCount = COUNT(0) FROM [procfwk].[CurrentExecution]
				SELECT @SuccessCount = COUNT(0) FROM [procfwk].[CurrentExecution] WHERE [PipelineStatus] = 'Success'

				IF @AllCount <> @SuccessCount
					BEGIN
						RAISERROR('Framework execution complete but not all Worker pipelines succeeded. See the [procfwk].[CurrentExecution] table for details',16,1);
						RETURN 0;
					END;
			END;

			--Do this if no error raised and when called by the execution wrapper (OverideRestart = 1).
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
				[procfwk].[CurrentExecution];

			TRUNCATE TABLE [procfwk].[CurrentExecution];
		END
	ELSE IF ([procfwk].[GetPropertyValueInternal]('UseExecutionBatches')) = '1'
		BEGIN
			IF @PerformErrorCheck = 1
			BEGIN
				--Check current execution
				SELECT 
					@AllCount = COUNT(0) 
				FROM 
					[procfwk].[CurrentExecution] 
				WHERE 
					[LocalExecutionId] = @ExecutionId;
				
				SELECT 
					@SuccessCount = COUNT(0) 
				FROM 
					[procfwk].[CurrentExecution] 
				WHERE 
					[LocalExecutionId] = @ExecutionId 
					AND [PipelineStatus] = 'Success';

				IF @AllCount <> @SuccessCount
					BEGIN
						UPDATE
							[procfwk].[BatchExecution]
						SET
							[BatchStatus] = 'Stopped',
							[EndDateTime] = GETUTCDATE()
						WHERE
							[ExecutionId] = @ExecutionId;
						
						RAISERROR('Framework execution complete for batch but not all Worker pipelines succeeded. See the [procfwk].[CurrentExecution] table for details',16,1);
						RETURN 0;
					END;
				ELSE
					BEGIN
						UPDATE
							[procfwk].[BatchExecution]
						SET
							[BatchStatus] = 'Success',
							[EndDateTime] = GETUTCDATE()
						WHERE
							[ExecutionId] = @ExecutionId;
					END;
			END; --end check

			--Do this if no error raised and when called by the execution wrapper (OverideRestart = 1).
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
				[LocalExecutionId] = @ExecutionId;

			DELETE FROM
				[procfwk].[CurrentExecution]
			WHERE
				[LocalExecutionId] = @ExecutionId;
		END;
END;