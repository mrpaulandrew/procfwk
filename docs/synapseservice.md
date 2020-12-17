# Azure Synapse Service

___
[<< Contents](/procfwk/contents) / [Functions](/procfwk/functions) / [Services](/procfwk/services)

___

## Key Name Spaces

* Microsoft.Rest
* Microsoft.Extensions.Logging
* Microsoft.IdentityModel.Clients.ActiveDirectory
* Microsoft.Azure.Management.Synapse
* Azure.Core
* Azure.Identity
* Azure.Analytics.Synapse.Artifacts
* Azure.Analytics.Synapse.Artifacts.Models

## Clients

* SynapseManagementClient
* PipelineClient
* PipelineRunClient



## Synapse Client Class (coming soon)

Methods:

### CreateSynapseClient

__Returns:__ Microsoft.Azure.Management.Synapse.SynapseManagementClient

__Role:__ Coming Soon

__Example Use:__
```csharp
using var client = SynapseClient.CreateSynapseClient(tenantId, applicationId, authenticationKey, subscriptionId);
```
___
