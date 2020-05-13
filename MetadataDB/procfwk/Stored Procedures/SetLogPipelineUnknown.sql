CREATE PROCEDURE [procfwk].[SetLogPipelineUnknown]
	(
	@ExecutionId UNIQUEIDENTIFIER,
	@StageId INT,
	@PipelineId INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ErrorDetail VARCHAR(500);

	--mark specific failure pipeline
	UPDATE
		[procfwk].[CurrentExecution]
	SET
		[PipelineStatus] = 'Unknown/Cancelled'
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId

	--persist unknown pipeline records to long term log
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
		[PipelineStatus] = 'Unknown/Cancelled'
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId;

	--block down stream stages?
	IF (
		SELECT
			[PropertyValue]
		FROM
			[procfwk].[CurrentProperties]
		WHERE
			[PropertyName] = 'UnknownWorkerResultBlocks'
		) = 1
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

		SET @ErrorDetail = 'Pipeline execution has an unknown status. Blocking downstream stages as a precaution.'

		RAISERROR(@ErrorDetail,16,1);
		RETURN 0;
	END
END;