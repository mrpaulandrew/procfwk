EXEC [procfwk].[AddProperty] 
	@PropertyName = 'TenantId',
	@PropertyValue = '1234-1234-1234-1234-1234',
	@Description = 'Used to provide authentication throughout the framework execution.'

EXEC [procfwk].[AddProperty] 
	@PropertyName = 'SubscriptionId',
	@PropertyValue = '1234-1234-1234-1234-1234',
	@Description = 'Used to provide authentication throughout the framework execution.'

EXEC [procfwk].[AddProperty]
	@PropertyName = N'OverideRestart',
	@PropertyValue = N'0',
	@Description = N'If set to 1, processing will not be restarted and a new execution will be created.'

EXEC [procfwk].[AddProperty]
	@PropertyName = N'PipelineStatusCheckDuration',
	@PropertyValue = N'60',
	@Description = N'Duration applied to the Wait activity within the Infant pipeline Until iterations.'