# ADF.procfwk Deployment Steps

The below are the steps you'll need to take to deployment the processsing framework to your environment. Currently these steps assume a new deployment is being done, rather than an upgrade from a previous version of the framework.

--------------------------------------------------------------------------------------------
1. Create an Azure Data Factory
2. Create an Azure SQLDB
3. Create an Azure Functions App
4. Create an Azure Key Vault
--------------------------------------------------------------------------------------------
5. Grant Data Factory access to Key Vault
6. Add the Function App default key to Key Vault as a secret
7. Add a SQLDB connection string to Key Vault as a secret
--------------------------------------------------------------------------------------------
8. Publish the SQLDB porject from Visual Studio
9. Publish the Function App from Visual Studio
10. Create a Service Principal for the deployment if you don't have one already...
11. Deploy Data Factory using the **DeployProcFwkComponents.ps1**
--------------------------------------------------------------------------------------------
12. Refresh Data Factory via the develop UI
13. Test all Linked Services connections (Key Vault, Functions and SQLDB)
14. Publish the Data Factory
--------------------------------------------------------------------------------------------
15. Run it :-)