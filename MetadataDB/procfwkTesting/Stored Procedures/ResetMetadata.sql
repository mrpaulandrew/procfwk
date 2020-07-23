CREATE PROCEDURE [procfwkTesting].[ResetMetadata]
AS
BEGIN	
	EXEC [procfwkHelpers].[SetDefaultProperties];
	EXEC [procfwkHelpers].[SetDefaultDataFactorys];
	EXEC [procfwkHelpers].[SetDefaultStages];
	EXEC [procfwkHelpers].[SetDefaultPipelines];
	EXEC [procfwkHelpers].[SetDefaultPipelineParameters];
	EXEC [procfwkHelpers].[SetDefaultPipelineDependants];
	EXEC [procfwkHelpers].[SetDefaultRecipients];
	EXEC [procfwkHelpers].[SetDefaultAlertOutcomes];
	EXEC [procfwkHelpers].[SetDefaultRecipientPipelineAlerts];
END;