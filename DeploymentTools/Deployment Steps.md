# ADF.procfwk Deployment Steps

Below are the basic steps you'll need to take to deployment the processing framework to your environment. Currently these steps assume a new deployment is being done, rather than an upgrade from a previous version of the framework.

Furthermore, in the case of most deployment steps, things can be tailored to your specific environment requirements. For example, using an existing SQL Database or Key Vault.

--------------------------------------------------------------------------------------------
1. Create an Azure Data Factory and connect it to source control - recommended, but not essential.
2. Create an Azure SQLDB and Logical SQL Instance.
3. Create an Azure Functions App with an App Service Plan if required.
4. Create an Azure Key Vault.
--------------------------------------------------------------------------------------------
5. Grant Data Factory access to Key Vault.
6. Add the Function App default key to Key Vault as a secret.
7. Add a SQLDB connection string to Key Vault as a secret using your preferred authentication method.
   - SQL Authentication.
   - Managed Service Identity. (**CREATE USER [##Data Factory Name##] FROM EXTERNAL PROVIDER;**)
--------------------------------------------------------------------------------------------
8. Publish the SQLDB project from Visual Studio creating a new publish profile if you don't have one already.
9. Publish the Function App from Visual Studio.
10. Create a Service Principal for the Data Factory deployment if you don't have one already.
11. Deploy Data Factory using the PowerShell script **DeployProcFwkComponents.ps1** and providing authentication details.
--------------------------------------------------------------------------------------------
12. Refresh Data Factory via the develop UI to review the components deployed.
13. Test all Linked Services connections (Key Vault, Functions and SQLDB) and update secrets as required.
14. Publish the Data Factory.
--------------------------------------------------------------------------------------------
15. Run it :-)