CREATE PROCEDURE [procfwk].[GetPipelineParameters]
	(
	@PipelineId INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Json VARCHAR(MAX) = ''

	--get parameters if required for worker pipeline
	IF NOT EXISTS
		(
		SELECT 
			[ParameterId] 
		FROM 
			[procfwk].[PipelineParameters] 
		WHERE 
			[PipelineId] = @PipelineId
		)
		BEGIN
			SET @Json = '' --Can't return NULL. Would break ADF expression.
		END
	ELSE
		BEGIN
			SELECT
				@Json += 
						CASE
							WHEN [ParameterValue] IS NULL THEN '' --don't add pair so ADF uses default
							ELSE '"' + [ParameterName] + '": "' + STRING_ESCAPE([ParameterValue],'json') + '",'
						END
			FROM
				[procfwk].[PipelineParameters]
			WHERE
				[PipelineId] = @PipelineId;
			
			--handle parameter(s) with a NULL values
			IF LEN(@Json) > 0
			BEGIN
				--JSON snippet gets injected into Azure Function body request via Data Factory expressions.
				--Comma used to support Data Factory expression.
				SET @Json = ',"pipelineParameters": {' + LEFT(@Json,LEN(@Json)-1) + '}'

				--update current execution log if this is a runtime request
				UPDATE
					[procfwk].[CurrentExecution]
				SET
					--add extra braces to make JSON string valid in logs
					[PipelineParamsUsed] = '{ ' + RIGHT(@Json,LEN(@Json)-1) + ' }'
				WHERE
				[PipelineId] = @PipelineId;
			END;
		END;

	--return JSON snippet
	SELECT @Json AS Params
END;