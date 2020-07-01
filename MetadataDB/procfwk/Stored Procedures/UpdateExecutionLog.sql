CREATE PROCEDURE [procfwk].[UpdateExecutionLog]
AS
BEGIN
	SET NOCOUNT ON;

	--check current execution
	DECLARE @AllCount INT
	DECLARE @SuccessCount INT

	SELECT @AllCount = COUNT(0) FROM [procfwk].[CurrentExecution]
	SELECT @SuccessCount = COUNT(0) FROM [procfwk].[CurrentExecution] WHERE [PipelineStatus] = 'Success'

	IF @AllCount <> @SuccessCount
		BEGIN
			RAISERROR('Framework execution complete but not all Worker pipelines succeeded. See the [procfwk].[CurrentExecution] table for details',16,1);
			RETURN 0;
		END;
	ELSE
		BEGIN
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
END;