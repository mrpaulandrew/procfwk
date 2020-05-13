CREATE PROCEDURE [procfwk].[SetLogPipelineFailed]
	(
	@ExecutionId UNIQUEIDENTIFIER,
	@StageId INT,
	@PipelineId INT,
	@RunId UNIQUEIDENTIFIER = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ErrorDetail VARCHAR(500)

	--mark specific failure pipeline
	UPDATE
		[procfwk].[CurrentExecution]
	SET
		[PipelineStatus] = 'Failed'
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
		[PipelineStatus] = 'Failed'
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId

	IF @RunId IS NOT NULL
		SET @ErrorDetail = 'Pipeline execution failed. Check Run ID: ' + CAST(@RunId AS CHAR(36)) + ' in ADF monitoring for details.'
	ELSE
		SET @ErrorDetail = 'Pipeline execution failed. See ADF monitoring for details.'

	RAISERROR(@ErrorDetail,16,1);
	RETURN 0;
END;