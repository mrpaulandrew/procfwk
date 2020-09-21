# Applying To Existing Data Factory Instances

___
[<< Contents](/procfwk/contents) 

___

The processing framework can be deployed to a green field environment and metadata added to support worker pipelines as they are created overtime. However, a more common approach is where an existing Data Factory instance has evolved to a point where it's pipeline are no longer managable and this framework is required. 

For the second deployment scenario and others the following PowerShell script and stored procedure can be used to help prepopulate the metadata database for an existing Data Factory instance, or many Data Factory's.

```powerhsell
$resourceGroupName = "YourResourceGroup"
$dataFactoryName = "ExistingDataFactory"
$region = "YourAzureRegion"

.\DeploymentTools\DataFactory\PopulatePipelinesInDb.ps1 `
    -SqlServerName '*****.database.windows.net' `
    -SqlDatabaseName 'MetadataDB' `
    -SqlUser 'user' `
    -SqlPass '******' `
    -resourceGroupName "$resourceGroupName" `
    -dataFactoryName "$dataFactoryName" `
    -region "$region"
```

Within this script, the underlying PowerShell cmdlet __Get-AzDataFactoryV2Pipeline__ is used to scrap a list of existing pipelines deployed to your Data Factory instance. The list of pipelines is then added to the metadata database using the stored procedure __[procfwkHelpers].[AddPipelineViaPowerShell]__. 

When used the stored procedure assumes a default tenant and subscription already exists, then adds the following:

* A new Data Factory, named as per the provided instance name.
* A new execution stage, named 'PoShAdded'.
* All the worker pipelines found.

Once complete, it is recommend that you distribute the worker pipelines across other execution stages and add the pipeline parameters as required.