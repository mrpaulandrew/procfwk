CREATE PROCEDURE [procfwk].[UpdateExecutionLog]
	(
	@PerformErrorCheck BIT = 1
	)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @AllCount INT
	DECLARE @SuccessCount INT

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
		[procfwk].[CurrentExecution];

	TRUNCATE TABLE [procfwk].[CurrentExecution];
END;