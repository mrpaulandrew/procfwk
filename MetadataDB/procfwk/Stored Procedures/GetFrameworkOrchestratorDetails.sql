CREATE PROCEDURE [procfwk].[GetFrameworkOrchestratorDetails]
	(
	@CallingOrchestratorName NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FrameworkOrchestrator NVARCHAR(200)

	--defensive check
	SELECT
		@FrameworkOrchestrator = UPPER([OrchestratorName]),
		@CallingOrchestratorName = UPPER(@CallingOrchestratorName)
	FROM
		[procfwk].[Orchestrators]
	WHERE
		[IsFrameworkOrchestrator] = 1;

	IF(@FrameworkOrchestrator <> @CallingOrchestratorName)
	BEGIN
		RAISERROR('Orchestrator mismatch. Calling orchestrator does not match expected IsFrameworkOrchestrator name.',16,1);
		RETURN 0;
	END

	--orchestrator detials
	SELECT
		[SubscriptionId],
		[ResourceGroupName],
		[OrchestratorName],
		[OrchestratorType]
	FROM
		[procfwk].[Orchestrators]
	WHERE
		[IsFrameworkOrchestrator] = 1;
END;