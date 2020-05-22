CREATE PROCEDURE [procfwk].[SetErrorLogDetails]
	(
	@LocalExecutionId UNIQUEIDENTIFIER,
	@JsonErrorDetails VARCHAR(MAX)
	)
AS
BEGIN
	SET NOCOUNT ON;

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
		ErrorDetail.[ActivityRunId],
		ErrorDetail.[ActivityName],
		ErrorDetail.[ActivityType],
		ErrorDetail.[ErrorCode],
		ErrorDetail.[ErrorType],
		ErrorDetail.[ErrorMessage]
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
			[ErrorCode] VARCHAR(100),
			[ErrorType] VARCHAR(100),
			[ErrorMessage] VARCHAR(MAX)
			) AS ErrorDetail
END;