CREATE PROCEDURE [procfwk].[CheckForBlockedPipelines]
	(
	@StageId INT
	)
AS

SET NOCOUNT ON;

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
			--reset started status for next stage
			UPDATE
				[procfwk].[CurrentExecution]
			SET
				[PipelineStatus] = 'Blocked'
			WHERE 
				[StageId] = @StageId
				AND [IsBlocked] = 1
			
			RAISERROR('Pipelines are blocked. Stopping processing.',16,1);
			RETURN;
		END

END