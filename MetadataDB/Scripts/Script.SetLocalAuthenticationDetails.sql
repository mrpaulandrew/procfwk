--Run in SQLCMD mode to use environment variables.

--Optional script used to setup function testing for processing framework parts post deployment.

PRINT 'TenantId: ' + '$(AZURE_TENANT_ID)'
PRINT 'SubscriptionId: ' + '$(AZURE_SUBSCRIPTION_ID)'

--Add new properties for your Azure tenant
EXEC [procfwkHelpers].[AddProperty] 
	@PropertyName = 'TenantId',
	@PropertyValue = '$(AZURE_TENANT_ID)',
	@Description = 'Used to provide authentication throughout the framework execution.'

EXEC [procfwkHelpers].[AddProperty] 
	@PropertyName = 'SubscriptionId',
	@PropertyValue = '$(AZURE_SUBSCRIPTION_ID)',
	@Description = 'Used to provide authentication throughout the framework execution.'

/*
EXEC [procfwkHelpers].[AddProperty]
	@PropertyName = N'SPNHandlingMethod',
	@PropertyValue = N'StoreInKeyVault',
	@Description = N'Accepted values: StoreInDatabase, StoreInKeyVault. See v1.8.2 release notes for full details.';
*/

IF (SELECT [procfwk].[GetPropertyValueInternal]('SPNHandlingMethod')) = 'StoreInDatabase'
	BEGIN
		--Add SPN for execution of all worker pipelines using database to store SPN values
		EXEC [procfwkHelpers].[AddServicePrincipalWrapper]
			@DataFactory = N'FrameworkFactory',
			@PrincipalIdValue = '$(AZURE_CLIENT_ID)',
			@PrincipalSecretValue = '$(AZURE_CLIENT_SECRET)',
			@PrincipalName = '$(AZURE_CLIENT_NAME)';

		--Add specific SPN for execution of Wait 1 pipeline (functional testing)	
		EXEC [procfwkHelpers].[DeleteServicePrincipal]
			@DataFactory = N'FrameworkFactory',
			@PrincipalIdValue = '$(AZURE_CLIENT_ID)',
			@SpecificPipelineName = N'Wait 1';

		EXEC [procfwkHelpers].[AddServicePrincipalWrapper]
			@DataFactory = N'FrameworkFactory',
			@PrincipalIdValue = '$(AZURE_CLIENT_ID_2)',
			@PrincipalSecretValue = '$(AZURE_CLIENT_SECRET_2)',
			@PrincipalName = '$(AZURE_CLIENT_NAME_2)',
			@SpecificPipelineName = N'Wait 1';
	END
ELSE IF (SELECT [procfwk].[GetPropertyValueInternal]('SPNHandlingMethod')) = 'StoreInKeyVault'
	BEGIN
		--Add SPN for execution of all worker pipelines using database to store key vault URLs
		EXEC [procfwkHelpers].[AddServicePrincipalWrapper]
			@DataFactory = N'FrameworkFactory',
			@PrincipalIdValue = '$(AZURE_CLIENT_ID_URL)',
			@PrincipalSecretValue = '$(AZURE_CLIENT_SECRET_URL)',
			@PrincipalName = '$(AZURE_CLIENT_NAME)';
	END
ELSE
	BEGIN
		RAISERROR('Unknown SPN insert method.',16,1);
	END;

SELECT * FROM [dbo].[ServicePrincipals];