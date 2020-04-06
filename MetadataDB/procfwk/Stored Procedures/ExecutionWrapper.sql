CREATE PROCEDURE [procfwk].[ExecutionWrapper]
	(
	@CallingDataFactory NVARCHAR(200)
	)
AS

SET NOCOUNT ON;

BEGIN
	
	DECLARE @RestartStatus BIT

	IF @CallingDataFactory IS NULL
		SET @CallingDataFactory = 'Unknown';

	--get restart overide property
	SELECT
		@RestartStatus = [PropertyValue] 
	FROM
		[procfwk].[CurrentProperties]
	WHERE
		[PropertyName] = 'OverideRestart'
	
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
			EXEC [procfwk].[CreateNewExecution] 
				@CallingDataFactoryName = @CallingDataFactory
		END
	--no restart considerations, just create new execution
	ELSE
		BEGIN
			EXEC [procfwk].[CreateNewExecution] 
				@CallingDataFactoryName = @CallingDataFactory
		END

END