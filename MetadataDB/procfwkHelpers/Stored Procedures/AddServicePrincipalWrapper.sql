CREATE PROCEDURE [procfwkHelpers].[AddServicePrincipalWrapper]
	(
	@DataFactory NVARCHAR(200),
	@PrincipalIdValue NVARCHAR(MAX),
	@PrincipalSecretValue NVARCHAR(MAX),
	@SpecificPipelineName NVARCHAR(200) = NULL,
	@PrincipalName NVARCHAR(256) = NULL
	)
AS
BEGIN
	
	IF ([procfwk].[GetPropertyValueInternal]('SPNHandlingMethod')) = 'StoreInDatabase'
		BEGIN
			EXEC [procfwk].[AddServicePrincipal]
				@DataFactory = @DataFactory,
				@PrincipalId = @PrincipalIdValue,
				@PrincipalSecret = @PrincipalSecretValue,
				@PrincipalName = @PrincipalName,
				@SpecificPipelineName = @SpecificPipelineName			
		END
	ELSE IF ([procfwk].[GetPropertyValueInternal]('SPNHandlingMethod')) = 'StoreInKeyVault'
		BEGIN
			EXEC [procfwk].[AddServicePrincipalUrls]
				@DataFactory = @DataFactory,
				@PrincipalIdUrl = @PrincipalIdValue,
				@PrincipalSecretUrl = @PrincipalSecretValue,
				@PrincipalName = @PrincipalName,
				@SpecificPipelineName = @SpecificPipelineName		
		END
	ELSE
		BEGIN
			RAISERROR('Unknown SPN insert method.',16,1);
			RETURN 0;
		END
END;
