# Azure Data Factory Service

___
[<< Contents](/procfwk/contents) / [Functions](/procfwk/functions) / [Services](/procfwk/services)

___

## Key Name Spaces

* Microsoft.Rest
* Microsoft.Extensions.Logging
* Microsoft.IdentityModel.Clients.ActiveDirectory
* Microsoft.Azure.Management.DataFactory
* Microsoft.Azure.Management.DataFactory.Models

## Clients

DataFactoryManagementClient



Methods:

### CreateDataFactoryClient

* tenantId
* applicationId
* authenticationKey
* subscriptionId

__Returns:__ Microsoft.Azure.Management.DataFactory.DataFactoryManagementClient

__Role:__ this helper is used by the execute pipeline, check pipeline status and get error details function to authenticate against the target worker data factory at runtime before invoking pipeline operation requests.

__Exmaple Use:__
```csharp
using (var client = DataFactoryClient.CreateDataFactoryClient(tenantId, applicationId, 
    authenticationKey, subscriptionId))
{
    PipelineRun pipelineRun;

    pipelineRun = client.PipelineRuns.Get(resourceGroup, factoryName, runResponse.RunId);
}
```
___
