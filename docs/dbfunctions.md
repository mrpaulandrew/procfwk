# Functions (Database)

___
[<< Contents](/procfwk/contents) / [Database](/procfwk/database)

___

The metadatabase database uses two very simple scalar functions to assist other [stored procedures](/procfwk/storedprocedure). These are as follows:

___

## GetPropertyValueInternal

__Schema:__ [procfwk](/procfwk/schemas)

__Input:__ @PropertyName VARCHAR(128)

__Output:__ @PropertyValue NVARCHAR(MAX)

__Role:__ the role of this function is to wrap up and return [property](/procfwk/properties) values from the database properties [table](/procfwk/tables) when required as part of other internal stored procedure logic. For example; when a stored procedure IF condition needs a property value as part of its valuation logic.

As the name suggests this scalar function is only used internally by other database objects. When the [orchestrator](/procfwk/orchestrators) requires a property value the [stored procedure](/procfwk/storedprocedure) [procfwk].[GetPropertyValue] is used.

__Example Use:__ 

```sql
IF ([procfwk].[GetPropertyValueInternal]('FailureHandling')) = 'DependencyChain'
BEGIN
    --output
END
```
___

## CheckForValidURL

__Schema:__ [procfwkHelpers](/procfwk/schemas)

__Input:__ @Url NVARCHAR(MAX)

__Output:__ RETURN 0 or 1; Depending on input string conditions.

__Role:__ as a helper function this is in turn used as part of the helper [stored procedure](/procfwk/storedprocedure) [procfwkHelpers].[AddServicePrincipalUrls]. When adding secret URL values that will later be retrieved from Azure Key Vault as part of the [SPN handling](/procfwk/spnhandling) behaviour the function performs soft validation at entry time to assist in ensuring the metadata is valid. The validation and string parsing is specific to a Key Vault Secret URL and isn't a generic validator for any URL. 

__Example Use:__ 

```sql
IF ([procfwkHelpers].[CheckForValidURL](@PrincipalIdUrl)) = 0
BEGIN
	SET @ErrorDetails = 'PrincipalIdUrl value is not in the expected format. . Please confirm the URL follows the structure https://{YourKeyVaultName}.vault.azure.net/secrets/{YourSecretName} and does not include the secret version guid.'
	PRINT @ErrorDetails;
END

IF ([procfwkHelpers].[CheckForValidURL](@PrincipalSecretUrl)) = 0
BEGIN
	SET @ErrorDetails = 'PrincipalSecretUrl value is not in the expected format. Please confirm the URL follows the structure https://{YourKeyVaultName}.vault.azure.net/secrets/{YourSecretName} and does not include the secret version guid.'
	PRINT @ErrorDetails;		
END
```

___