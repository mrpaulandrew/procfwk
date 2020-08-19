# ADF.procfwk Deployment Steps

Below are the basic steps you'll need to take to deployment the processing framework to your environment. Currently these steps assume a new deployment is being done, rather than an upgrade from a previous version of the framework.

Furthermore, in the case of most deployment steps, things can be tailored to your specific environment requirements. For example, using an existing SQL Database or Key Vault.

--------------------------------------------------------------------------------------------
1. Create an Azure Data Factory and connect it to source control - recommended, but not essential.
2. Create an Azure SQLDB and Logical SQL Instance.
3. Create an Azure Functions App with an App Service Plan if required. A Consumption Plan is also fine.
4. Create an Azure Key Vault.
--------------------------------------------------------------------------------------------
5. Grant Data Factory access to Key Vault with its MSI and set the Key Vault Access Policy.
6. Add the Function App default key to Key Vault as a secret.
7. Add a SQLDB connection string to Key Vault as a secret using your preferred authentication method.
   - SQL Authentication.
   - Managed Service Identity. (**CREATE USER [##Data Factory Name##] FROM EXTERNAL PROVIDER;**)
--------------------------------------------------------------------------------------------
8. Publish the SQLDB project from Visual Studio creating a new publish profile if you don't have one already.
9. Publish the Function App from Visual Studio.
10. Create a Service Principal for the Data Factory deployment if you don't have one already.
11. Create a Service Principal for the Data Factory pipeline executions if you don't have one already.
12. Deploy Data Factory using the PowerShell script **DeployProcFwkComponents.ps1** and providing authentication details.
--------------------------------------------------------------------------------------------
13. Refresh Data Factory via the develop UI to review the components deployed.
14. Test all Linked Services connections (Key Vault, Functions and SQLDB) and update secrets as required.
15. Publish the Data Factory.
--------------------------------------------------------------------------------------------
16. Set your Subscription ID in the properties table.
17. Set your Tenant ID in the properties table. Its important that you do this first to later support the SPN details added.
18. Add a target Data Factory where you Worker pipelines exist.
19. Add your Worker Pipeline and Stages metadata as required. The PowerShell script **PopulatePipelinesInDb.ps1** can help with this.
20. Set the property 'SPNHandlingMethod' to your preferred method of handling. Via the metadata database directly or using Azure Key Vault.
21. Add your SPN details from step 11 to your metadata directly or using Key Vault URLs. Use the stored procedure **[procfwk].[AddServicePrincipalWrapper].**
22. Add pipeline parameters as required.
23. Add recipients for email alerting, optional. Use the stored procedure **[procfwk].[AddRecipientPipelineAlerts]**.
24. Set the property 'FailureHandling' to your preferred method of handling.
--------------------------------------------------------------------------------------------
25. Run it :-)