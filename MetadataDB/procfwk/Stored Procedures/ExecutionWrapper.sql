CREATE PROCEDURE [procfwk].[ExecutionWrapper]
	(
	@CallingDataFactory NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RestartStatus BIT

	IF @CallingDataFactory IS NULL
		SET @CallingDataFactory = 'Unknown';

	--get restart overide property	
	SELECT @RestartStatus = [procfwk].[GetPropertyValueInternal]('OverideRestart')

	--check for running execution
	IF EXISTS
		(
		SELECT * FROM [procfwk].[CurrentExecution] WHERE ISNULL([PipelineStatus],'') = 'Running'
		)
		BEGIN
			RAISERROR('There is already an execution run in progress. Stop this via Data Factory before restarting.',16,1);
			RETURN 0;
		END;	

	--reset and restart execution
	IF EXISTS
		(
		SELECT * FROM [procfwk].[CurrentExecution] WHERE ISNULL([PipelineStatus],'') <> 'Success'
		) 
		AND @RestartStatus = 0
		BEGIN
			EXEC [procfwk].[ResetExecution]
		END
	--capture failed execution and run new anyway
	ELSE IF EXISTS
		(
		SELECT * FROM [procfwk].[CurrentExecution]
		)
		AND @RestartStatus = 1
		BEGIN
			EXEC [procfwk].[UpdateExecutionLog]
				@PerformErrorCheck = 0; --Special case when OverideRestart = 1;

			EXEC [procfwk].[CreateNewExecution] 
				@CallingDataFactoryName = @CallingDataFactory
		END
	--no restart considerations, just create new execution
	ELSE
		BEGIN
			EXEC [procfwk].[CreateNewExecution] 
				@CallingDataFactoryName = @CallingDataFactory
		END
END;