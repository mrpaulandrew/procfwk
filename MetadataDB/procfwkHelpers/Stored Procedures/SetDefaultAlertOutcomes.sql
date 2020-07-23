CREATE PROCEDURE [procfwkHelpers].[SetDefaultAlertOutcomes]
AS
BEGIN
	TRUNCATE TABLE [procfwk].[AlertOutcomes];

	INSERT INTO [procfwk].[AlertOutcomes] 
		(
		[PipelineOutcomeStatus]
		)
	VALUES 
		('All'),
		('Success'),
		('Failed'),
		('Unknown'),
		('Cancelled');
END;