CREATE PROCEDURE [procfwk].[CheckForBlockedPipelines]
	(
	@StageId INT
	)
AS
BEGIN

	SET NOCOUNT ON;

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
			RETURN 0;
		END
END;