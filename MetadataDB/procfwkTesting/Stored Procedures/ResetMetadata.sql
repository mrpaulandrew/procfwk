CREATE PROCEDURE [procfwkTesting].[ResetMetadata]
AS
BEGIN	
	EXEC [procfwkHelpers].[SetDefaultProperties];
	EXEC [procfwkHelpers].[SetDefaultTenant];
	EXEC [procfwkHelpers].[SetDefaultSubscription];
	EXEC [procfwkHelpers].[SetDefaultDataFactorys];
	EXEC [procfwkHelpers].[SetDefaultBatches];
	EXEC [procfwkHelpers].[SetDefaultStages];
	EXEC [procfwkHelpers].[SetDefaultBatchStageLink];
	EXEC [procfwkHelpers].[SetDefaultPipelines];
	EXEC [procfwkHelpers].[SetDefaultPipelineParameters];
	EXEC [procfwkHelpers].[SetDefaultPipelineDependants];
	EXEC [procfwkHelpers].[SetDefaultRecipients];
	EXEC [procfwkHelpers].[SetDefaultAlertOutcomes];
	EXEC [procfwkHelpers].[SetDefaultRecipientPipelineAlerts];
END;