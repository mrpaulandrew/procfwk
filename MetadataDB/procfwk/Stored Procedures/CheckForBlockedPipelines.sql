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
			RAISERROR('Pipelines are blocked. Stopping processing.',16,1);
			RETURN;
		END

END