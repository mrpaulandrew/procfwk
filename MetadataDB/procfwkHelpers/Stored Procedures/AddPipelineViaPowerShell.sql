CREATE PROCEDURE [procfwkHelpers].[AddPipelineViaPowerShell]
	(
	@ResourceGroup NVARCHAR(200),
	@DataFactoryName NVARCHAR(200),
	@PipelineName NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataFactoryId INT
	DECLARE @StageId INT
	DECLARE @StageName VARCHAR(255) = 'PoShAdded'

	--get/set data factory
	IF EXISTS
		(
		SELECT * FROM [procfwk].[DataFactorys] WHERE [DataFactoryName] = @DataFactoryName AND [ResourceGroupName] = @ResourceGroup
		)
		BEGIN
			SELECT @DataFactoryId = [DataFactoryId] FROM [procfwk].[DataFactorys] WHERE [DataFactoryName] = @DataFactoryName AND [ResourceGroupName] = @ResourceGroup;
		END
	ELSE
		BEGIN
			INSERT INTO [procfwk].[DataFactorys]
				(
				[DataFactoryName],
				[ResourceGroupName],
				[Description]
				)
			VALUES
				(
				@DataFactoryName,
				@ResourceGroup,
				'Added via PowerShell.'
				)

			SELECT
				@DataFactoryId = SCOPE_IDENTITY();
		END

	--get/set stage
	IF EXISTS
		(
		SELECT * FROM [procfwk].[Stages] WHERE [StageName] = @StageName
		)
		BEGIN
			SELECT @StageId = [StageId] FROM [procfwk].[Stages] WHERE [StageName] = @StageName;
		END;
	ELSE
		BEGIN
			INSERT INTO [procfwk].[Stages]
				(
				[StageName],
				[StageDescription],
				[Enabled]
				)
			VALUES
				(
				@StageName,
				'Added via PowerShell.',
				1
				);

			SELECT
				@StageId = SCOPE_IDENTITY();
		END;

	--upsert pipeline
	;WITH sourceData AS
		(
		SELECT
			@DataFactoryId AS DataFactoryId,
			@PipelineName AS PipelineName,
			@StageId AS StageId,
			NULL AS LogicalPredecessorId,
			1 AS [Enabled]
		)
	MERGE INTO [procfwk].[Pipelines] AS tgt
	USING 
		sourceData AS src
			ON tgt.[DataFactoryId] = src.[DataFactoryId]
				AND tgt.[PipelineName] = src.[PipelineName]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[StageId] = src.[StageId],
			tgt.[LogicalPredecessorId] = src.[LogicalPredecessorId],
			tgt.[Enabled] = src.[Enabled]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[DataFactoryId],
			[StageId],
			[PipelineName], 
			[LogicalPredecessorId],
			[Enabled]
			)
		VALUES
			(
			src.[DataFactoryId],
			src.[StageId],
			src.[PipelineName], 
			src.[LogicalPredecessorId],
			src.[Enabled]
			);
END;