CREATE PROCEDURE [procfwk].[CreateNewExecution]
	(
	@CallingDataFactoryName NVARCHAR(200),
	@LocalExecutionId UNIQUEIDENTIFIER = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @BatchId UNIQUEIDENTIFIER;

	IF([procfwk].[GetPropertyValueInternal]('UseExecutionBatches')) = '0'
		BEGIN
			SET @LocalExecutionId = NEWID();

			TRUNCATE TABLE [procfwk].[CurrentExecution];

			INSERT INTO [procfwk].[CurrentExecution]
				(
				[LocalExecutionId],
				[StageId],
				[PipelineId],
				[CallingDataFactoryName],
				[ResourceGroupName],
				[DataFactoryName],
				[PipelineName]
				)
			SELECT
				@LocalExecutionId,
				p.[StageId],
				p.[PipelineId],
				@CallingDataFactoryName,
				d.[ResourceGroupName],
				d.[DataFactoryName],
				p.[PipelineName]
			FROM
				[procfwk].[Pipelines] p
				INNER JOIN [procfwk].[Stages] s
					ON p.[StageId] = s.[StageId]
				INNER JOIN [procfwk].[DataFactorys] d
					ON p.[DataFactoryId] = d.[DataFactoryId]
			WHERE
				p.[Enabled] = 1
				AND s.[Enabled] = 1;

			SELECT
				@LocalExecutionId AS ExecutionId;
		END
	ELSE IF ([procfwk].[GetPropertyValueInternal]('UseExecutionBatches')) = '1'
		BEGIN
			DELETE FROM 
				[procfwk].[CurrentExecution]
			WHERE
				[LocalExecutionId] = @LocalExecutionId;

			SELECT
				@BatchId = [BatchId]
			FROM
				[procfwk].[BatchExecution]
			WHERE
				[ExecutionId] = @LocalExecutionId;

			INSERT INTO [procfwk].[CurrentExecution]
				(
				[LocalExecutionId],
				[StageId],
				[PipelineId],
				[CallingDataFactoryName],
				[ResourceGroupName],
				[DataFactoryName],
				[PipelineName]
				)
			SELECT
				@LocalExecutionId,
				p.[StageId],
				p.[PipelineId],
				@CallingDataFactoryName,
				d.[ResourceGroupName],
				d.[DataFactoryName],
				p.[PipelineName]
			FROM
				[procfwk].[Pipelines] p
				INNER JOIN [procfwk].[Stages] s
					ON p.[StageId] = s.[StageId]
				INNER JOIN [procfwk].[DataFactorys] d
					ON p.[DataFactoryId] = d.[DataFactoryId]
				INNER JOIN [procfwk].[BatchStageLink] b
					ON b.[StageId] = s.[StageId]
			WHERE
				b.[BatchId] = @BatchId
				AND p.[Enabled] = 1
				AND s.[Enabled] = 1;
				
			SELECT
				@LocalExecutionId AS ExecutionId;
		END;

	ALTER INDEX [IDX_GetPipelinesInStage] ON [procfwk].[CurrentExecution]
	REBUILD;
END;