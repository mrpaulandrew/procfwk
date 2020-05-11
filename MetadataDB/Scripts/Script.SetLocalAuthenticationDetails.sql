--Run in SQLCMD mode to use environment variables.

--Optional script used to setup function testing for processing framework parts post deployment.

PRINT 'TenantId: ' + '$(AZURE_TENANT_ID)'
PRINT 'SubscriptionId: ' + '$(AZURE_SUBSCRIPTION_ID)'

--Add new properties for your Azure tenant
EXEC [procfwk].[AddProperty] 
	@PropertyName = 'TenantId',
	@PropertyValue = '$(AZURE_TENANT_ID)',
	@Description = 'Used to provide authentication throughout the framework execution.'

EXEC [procfwk].[AddProperty] 
	@PropertyName = 'SubscriptionId',
	@PropertyValue = '$(AZURE_SUBSCRIPTION_ID)',
	@Description = 'Used to provide authentication throughout the framework execution.'

--Add SPN for execution of all worker pipelines
EXEC [procfwk].[AddServicePrincipal]
	@DataFactory = N'FrameworkFactory',
	@PrincipalId = '$(AZURE_CLIENT_ID)',
	@PrincipalSecret = '$(AZURE_CLIENT_SECRET)',
	@PrincipalName = '$(AZURE_CLIENT_NAME)'

--Add specific SPN for execution of Wait 1 pipeline (functional testing)	
EXEC [procfwk].[DeleteServicePrincipal]
	@DataFactory = N'FrameworkFactory',
	@PrincipalId = '$(AZURE_CLIENT_ID)',
	@SpecificPipelineName = N'Wait 1'

EXEC [procfwk].[AddServicePrincipal]
	@DataFactory = N'FrameworkFactory',
	@PrincipalId = '$(AZURE_CLIENT_ID_2)',
	@PrincipalSecret = '$(AZURE_CLIENT_SECRET_2)',
	@PrincipalName = '$(AZURE_CLIENT_NAME_2)',
	@SpecificPipelineName = N'Wait 1'