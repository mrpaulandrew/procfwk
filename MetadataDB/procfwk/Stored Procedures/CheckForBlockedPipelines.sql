CREATE PROCEDURE [procfwk].[CheckForBlockedPipelines]
	(
	@StageId INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF ([procfwk].[GetPropertyValueInternal]('FailureHandling')) = 'None'
		BEGIN
			--do nothing allow processing to carry on regardless
			RETURN 0;
		END;
		
	ELSE IF ([procfwk].[GetPropertyValueInternal]('FailureHandling')) = 'Simple'
		BEGIN
			IF EXISTS
				(
				SELECT 
					*
				FROM 
					[procfwk].[CurrentExecution]
				WHERE 
					[StageId] = @StageId
					AND [IsBlocked] = 1
				)
				BEGIN		
					--Saves the child pipeline and activities being called throwing the exception at this level.
					RAISERROR('All pipelines are blocked. Stopping processing.',16,1); 
					--If not thrown here, the proc [procfwk].[UpdateExecutionLog] would eventually throw an exception.
					RETURN 0;
				END			
		END;
	
	ELSE IF ([procfwk].[GetPropertyValueInternal]('FailureHandling')) = 'DependencyChain'
		BEGIN
			IF EXISTS
				(
				SELECT 
					*
				FROM 
					[procfwk].[CurrentExecution]
				WHERE 
					[StageId] = @StageId
					AND [IsBlocked] = 1
				)
				BEGIN		
					DECLARE @PipelineId INT;
					DECLARE @Cursor CURSOR ;

					SET @Cursor = CURSOR FOR 
											SELECT 
												[PipelineId] 
											FROM 
												[procfwk].[CurrentExecution] 
											WHERE 
												[StageId] = @StageId 
												AND [IsBlocked] = 1

					OPEN @Cursor
					FETCH NEXT FROM @Cursor INTO @PipelineId
					
					WHILE @@FETCH_STATUS = 0
					BEGIN 
						EXEC [procfwk].[SetExecutionBlockDependants]
							@PipelineId = @PipelineId;
						
						FETCH NEXT FROM @Cursor INTO @PipelineId;
					END;
					CLOSE @Cursor;
					DEALLOCATE @Cursor;
				END;
		END;
	ELSE
		BEGIN
			RAISERROR('Unknown failure handling state.',16,1);
			RETURN 0;
		END;
END;