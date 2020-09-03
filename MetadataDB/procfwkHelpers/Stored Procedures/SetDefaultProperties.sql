CREATE PROCEDURE [procfwkHelpers].[SetDefaultProperties]
AS
BEGIN
	EXEC [procfwkHelpers].[AddProperty] 
		@PropertyName = 'TenantId',
		@PropertyValue = '1234-1234-1234-1234-1234',
		@Description = 'Used to provide authentication throughout the framework execution.';

	EXEC [procfwkHelpers].[AddProperty] 
		@PropertyName = 'SubscriptionId',
		@PropertyValue = '1234-1234-1234-1234-1234',
		@Description = 'Used to provide authentication throughout the framework execution.';

	EXEC [procfwkHelpers].[AddProperty]
		@PropertyName = N'OverideRestart',
		@PropertyValue = N'0',
		@Description = N'Should processing not be restarted from the point of failure or should a new execution will be created regardless. 1 = Start New, 0 = Restart. ';

	EXEC [procfwkHelpers].[AddProperty]
		@PropertyName = N'PipelineStatusCheckDuration',
		@PropertyValue = N'30',
		@Description = N'Duration applied to the Wait activity within the Infant pipeline Until iterations.';

	EXEC [procfwkHelpers].[AddProperty]
		@PropertyName = N'UnknownWorkerResultBlocks',
		@PropertyValue = N'1',
		@Description = N'If a worker pipeline returns an unknown status. Should this block and fail downstream pipeline? 1 = Yes, 0 = No.';

	EXEC [procfwkHelpers].[AddProperty]
		@PropertyName = N'CancelledWorkerResultBlocks',
		@PropertyValue = N'1',
		@Description = N'If a worker pipeline returns an cancelled status. Should this block and fail downstream pipeline? 1 = Yes, 0 = No.';

	EXEC [procfwkHelpers].[AddProperty]
		@PropertyName = N'UseFrameworkEmailAlerting',
		@PropertyValue = N'1',
		@Description = N'Do you want the framework to handle pipeline email alerts via the database metadata? 1 = Yes, 0 = No.';

	EXEC [procfwkHelpers].[AddProperty]
		@PropertyName = N'EmailAlertBodyTemplate',
		@PropertyValue = 
		N'<hr/><strong>Pipeline Name: </strong>##PipelineName###<br/>
	<strong>Status: </strong>##Status###<br/><br/>
	<strong>Execution ID: </strong>##ExecId###<br/>
	<strong>Run ID: </strong>##RunId###<br/><br/>
	<strong>Start Date Time: </strong>##StartDateTime###<br/>
	<strong>End Date Time: </strong>##EndDateTime###<br/>
	<strong>Duration (Minutes): </strong>##Duration###<br/><br/>
	<strong>Called by Data Factory: </strong>##CalledByADF###<br/>
	<strong>Executed by Data Factory: </strong>##ExecutedByADF###<br/><hr/>',
		@Description = N'Basic HTML template of execution information used as the eventual body in email alerts sent.';

	EXEC [procfwkHelpers].[AddProperty]
		@PropertyName = N'FailureHandling',
		@PropertyValue = N'Simple',
		@Description = N'Accepted values: None, Simple, DependencyChain. Controls processing bahaviour in the event of Worker failures. See v1.8 release notes for full details.';

	EXEC [procfwkHelpers].[AddProperty]
		@PropertyName = N'SPNHandlingMethod',
		@PropertyValue = N'StoreInDatabase',
		@Description = N'Accepted values: StoreInDatabase, StoreInKeyVault. See v1.8.2 release notes for full details.';

	EXEC [procfwkHelpers].[AddProperty]
		@PropertyName = N'ExecutionPrecursorProc',
		@PropertyValue = N'[dbo].[ExampleCustomExecutionPrecursor]',
		@Description = N'This procedure will be called first in the parent pipeline and can be used to perform/update any required custom behaviour in the framework execution. For example, enable/disable Worker pipelines given a certain run time/day. Invalid proc name values will be ignored.'
END;