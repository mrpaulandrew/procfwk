CREATE   PROCEDURE [procfwk].[ResetExecution]
AS

BEGIN 
		
	--reset status ready for next attempt
	UPDATE
		[procfwk].[CurrentExecution]
	SET
		[StartDateTime] = NULL,
		[PipelineStatus] = NULL,
		[IsBlocked] = 0
	WHERE
		[PipelineStatus] = 'Failed'
		OR [IsBlocked] = 1
	
	--return current execution id
	SELECT DISTINCT
		[LocalExecutionId] AS 'ExecutionId'
	FROM
		[procfwk].[CurrentExecution]

END