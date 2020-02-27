
CREATE PROCEDURE procfwk.UpdateExecutionLog
AS

SET NOCOUNT ON;

BEGIN

	INSERT INTO [procfwk].[ExecutionLog]
		(
		[LocalExecutionId],
		[StageId],
		[PipelineId],
		[PipelineName],
		[StartDateTime],
		[PipelineStatus],
		[EndDateTime]
		)
	SELECT
		[LocalExecutionId],
		[StageId],
		[PipelineId],
		[PipelineName],
		[StartDateTime],
		[PipelineStatus],
		[EndDateTime]
	FROM
		[procfwk].[CurrentExecution]

	TRUNCATE TABLE [procfwk].[CurrentExecution];

END
