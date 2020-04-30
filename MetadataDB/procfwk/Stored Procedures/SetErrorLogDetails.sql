CREATE PROCEDURE [procfwk].[SetErrorLogDetails]
	(
	@LocalExecutionId UNIQUEIDENTIFIER,
	@JsonErrorDetails VARCHAR(MAX)
	)
AS
BEGIN
	
	INSERT INTO [procfwk].[ErrorLog]
		(
		[LocalExecutionId],
		[AdfPipelineRunId],
		[ActivityRunId],
		[ActivityName],
		[ActivityType],
		[ErrorCode],
		[ErrorType],
		[ErrorMessage]
		)
	SELECT
		@LocalExecutionId,
		Base.[RunId],
		Errors.[ActivityRunId],
		Errors.[ActivityName],
		Errors.[ActivityType],
		Errors.[ErrorCode],
		Errors.[ErrorType],
		Errors.[ErrorMessage]
	FROM 
		OPENJSON(@JsonErrorDetails) WITH
			( 
			[RunId] UNIQUEIDENTIFIER,
			[Errors] NVARCHAR(MAX) AS JSON
			) AS Base
		CROSS APPLY OPENJSON (Base.[Errors]) WITH
			(
			[ActivityRunId] UNIQUEIDENTIFIER,
			[ActivityName] VARCHAR(100),
			[ActivityType] VARCHAR(100),
			[ErrorCode] INT,
			[ErrorType] VARCHAR(100),
			[ErrorMessage] VARCHAR(MAX)
			) AS Errors
END