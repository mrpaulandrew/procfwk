CREATE PROCEDURE [procfwkHelpers].[SetDefaultRecipientPipelineAlerts]
AS
BEGIN
	EXEC [procfwkHelpers].[AddRecipientPipelineAlerts]
		@RecipientName = N'Test User 1',
		@AlertForStatus = 'All';

	EXEC [procfwkHelpers].[AddRecipientPipelineAlerts]
		@RecipientName = N'Test User 2',
		@PipelineName = 'Intentional Error',
		@AlertForStatus = 'Failed';

	EXEC [procfwkHelpers].[AddRecipientPipelineAlerts]
		@RecipientName = N'Test User 3',
		@PipelineName = 'Wait 1',
		@AlertForStatus = 'Success, Failed, Cancelled';	
END;