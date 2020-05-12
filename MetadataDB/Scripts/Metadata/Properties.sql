EXEC [procfwk].[AddProperty] 
	@PropertyName = 'TenantId',
	@PropertyValue = '1234-1234-1234-1234-1234',
	@Description = 'Used to provide authentication throughout the framework execution.';

EXEC [procfwk].[AddProperty] 
	@PropertyName = 'SubscriptionId',
	@PropertyValue = '1234-1234-1234-1234-1234',
	@Description = 'Used to provide authentication throughout the framework execution.';

EXEC [procfwk].[AddProperty]
	@PropertyName = N'OverideRestart',
	@PropertyValue = N'0',
	@Description = N'Should processing not be restarted from the point of failure or should a new execution will be created regardless. 1 = Start New, 0 = Restart. ';

EXEC [procfwk].[AddProperty]
	@PropertyName = N'PipelineStatusCheckDuration',
	@PropertyValue = N'30',
	@Description = N'Duration applied to the Wait activity within the Infant pipeline Until iterations.';

EXEC [procfwk].[AddProperty]
	@PropertyName = N'UnknownWorkerResultBlocks',
	@PropertyValue = N'1',
	@Description = N'If a worker pipeline returns an unknown status. Eg. Cancelled. Should this block and fail downstream pipeline? 1 = Yes, 0 = No.';