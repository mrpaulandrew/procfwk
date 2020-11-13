CREATE PROCEDURE [procfwk].[BatchWrapper]
	(
	@BatchId UNIQUEIDENTIFIER,
	@LocalExecutionId UNIQUEIDENTIFIER OUTPUT
	)
AS
BEGIN
	SET NOCOUNT ON;

	--check for running batch execution
	IF EXISTS
		(
		SELECT 1 FROM [procfwk].[BatchExecution] WHERE [BatchId] = @BatchId AND ISNULL([BatchStatus],'') = 'Running'
		)
		BEGIN
			SELECT
				@LocalExecutionId = [ExecutionId]
			FROM
				[procfwk].[BatchExecution]
			WHERE
				[BatchId] = @BatchId;

			RAISERROR('There is already an batch execution run in progress. Stop the related parent pipeline via Data Factory first.',16,1);
			RETURN 0;
		END
	ELSE IF EXISTS
		(
		SELECT 1 FROM [procfwk].[BatchExecution] WHERE [BatchId] = @BatchId AND ISNULL([BatchStatus],'') = 'Stopped'
		)
		BEGIN
			SELECT
				@LocalExecutionId = [ExecutionId]
			FROM
				[procfwk].[BatchExecution]
			WHERE
				[BatchId] = @BatchId
				AND ISNULL([BatchStatus],'') = 'Stopped';

			RETURN 0;
		END
	ELSE
		BEGIN
			SET @LocalExecutionId = NEWID();

			--create new batch run record
			INSERT INTO [procfwk].[BatchExecution]
				(
				[BatchId],
				[ExecutionId],
				[BatchName],
				[BatchStatus],
				[StartDateTime]
				)
			SELECT
				[BatchId],
				@LocalExecutionId,
				[BatchName],
				'Running',
				GETUTCDATE()
			FROM
				[procfwk].[Batches]
			WHERE
				[BatchId] = @BatchId;
		END;
END;