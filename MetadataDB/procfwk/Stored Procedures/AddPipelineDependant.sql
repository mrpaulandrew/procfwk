CREATE PROCEDURE [procfwk].[AddPipelineDependant]
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
	IF @PipelineId = @DependantPipelineId
	BEGIN
		RAISERROR('Pipeline cannot be dependant on itself.', 16,1);
		RETURN 0;
	END;

	IF @PipelineId IS NULL
	BEGIN
		RAISERROR('Pipeline not found in pipelines table.', 16,1);
		RETURN 0;
	END;

	IF @DependantPipelineId IS NULL
	BEGIN
		RAISERROR('Dependant pipeline not found in pipelines table.', 16,1);
		RETURN 0;
	END

	--final check and insert
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
