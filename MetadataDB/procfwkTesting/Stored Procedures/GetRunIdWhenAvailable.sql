CREATE PROCEDURE [procfwkTesting].[GetRunIdWhenAvailable]
	(
	@PipelineName NVARCHAR(200) = NULL
	)
AS
BEGIN
	IF @PipelineName IS NULL
		BEGIN
			WHILE 1=1
			BEGIN
				IF EXISTS
					(
					SELECT TOP 1 
						[PipelineRunId] 
					FROM 
						[procfwk].[CurrentExecution] 
					WHERE 
						[PipelineRunId] IS NOT NULL
					)
				BEGIN
					BREAK;
				END

				WAITFOR DELAY '00:00:10';
			END;

			SELECT TOP 1 
				CAST([PipelineRunId] AS VARCHAR(36)) AS RunId 
			FROM 
				[procfwk].[CurrentExecution] 
			WHERE 
				[PipelineRunId] IS NOT NULL
		END
	ELSE IF @PipelineName IS NOT NULL
		BEGIN
			WHILE 1=1
			BEGIN
				IF EXISTS
					(
					SELECT TOP 1 
						[PipelineRunId] 
					FROM 
						[procfwk].[CurrentExecution] 
					WHERE 
						[PipelineRunId] IS NOT NULL 
						AND [PipelineName] = @PipelineName
					)
				BEGIN
					BREAK;
				END

				WAITFOR DELAY '00:00:10';
			END;

			SELECT TOP 1 
				CAST([PipelineRunId] AS VARCHAR(36)) AS RunId 
			FROM 
				[procfwk].[CurrentExecution] 
			WHERE 
				[PipelineRunId] IS NOT NULL
				AND [PipelineName] = @PipelineName
		END
	ELSE
		BEGIN
			RAISERROR('Unknown use of testing procedure.',16,1);
		END
END;