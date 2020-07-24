CREATE PROCEDURE [procfwkHelpers].[AddPipelineDependant]
	(
	@PipelineName NVARCHAR(200),
	@DependantPipelineName NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PipelineId INT;
	DECLARE @DependantPipelineId INT;

	--get pipeline ids
	SELECT
		@PipelineId = [PipelineId]
	FROM
		[procfwk].[Pipelines]
	WHERE
		[PipelineName] = @PipelineName;

	SELECT
		@DependantPipelineId = [PipelineId]
	FROM
		[procfwk].[Pipelines]
	WHERE
		[PipelineName] = @DependantPipelineName;

	--defensive checks
	IF @PipelineId IS NULL
	BEGIN
		RAISERROR('Pipeline not found in pipelines table.', 16,1);
		RETURN 0;
	END;

	IF @DependantPipelineId IS NULL
	BEGIN
		RAISERROR('Dependant pipeline not found in pipelines table.', 16,1);
		RETURN 0;
	END;

	IF @PipelineId = @DependantPipelineId
	BEGIN
		RAISERROR('Pipeline cannot be dependant on itself.', 16,1);
		RETURN 0;
	END;

	IF EXISTS
		(
		SELECT 
			*
		FROM 
			[procfwk].[Pipelines] pp
			INNER JOIN [procfwk].[Pipelines] dp
				ON dp.[PipelineId] = @DependantPipelineId
		WHERE
			pp.[PipelineId] = @PipelineId
			AND pp.[StageId] = dp.[StageId]
		)
		BEGIN
			RAISERROR('Pipeline and dependent pipeline cannot be in the same execution stage.', 16,1);
			RETURN 0;
		END;

	--final soft check and insert
	IF EXISTS
		(
		SELECT 
			* 
		FROM 
			[procfwk].[PipelineDependencies] 
		WHERE
			[PipelineId] = @PipelineId
			AND [DependantPipelineId] = @DependantPipelineId
		)
		BEGIN
			PRINT 'Dependency already exists. Nothing added.'
			RETURN 0;
		END
	ELSE
		BEGIN
			INSERT INTO [procfwk].[PipelineDependencies]
				(
				[PipelineId],
				[DependantPipelineId]
				)
			VALUES
				(
				@PipelineId,
				@DependantPipelineId
				)
		END;
END;
