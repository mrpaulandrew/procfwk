CREATE   PROCEDURE [procfwk].[GetProcessStages]
	(
	@ExecutionId UNIQUEIDENTIFIER
	)
AS

SET NOCOUNT ON;

BEGIN

	SELECT DISTINCT 
		[StageId] 
	FROM 
		[procfwk].[CurrentExecution]
	WHERE
		[LocalExecutionId] = @ExecutionId
	ORDER BY 
		[StageId] ASC

END