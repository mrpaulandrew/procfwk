# Pipeline Request

___
[<< Contents](/procfwk/contents) / [Functions](/procfwk/functions) / [Helpers](/procfwk/helpers)

___

## Role

To provide a common validated set of pipeline request properties to be used with all worker pipeline interactions.

Namespace: __mrpaulandrew.azure.procfwk.Helpers__.

## Properties

| Property Name | Type |
|------------|-------------|
| TenantId | string |
| SubscriptionId | string |
| AuthenticationKey | string |
| SubscriptionId | string |
| ResourceGroupName | string |
| OrchestratorName | string |
| OrchestratorType | [PipelineServiceType](/procfwk/servicetype) |
| PipelineName | string |
| PipelineParameters | Dictionary<string, string> |

## Methods

### Validate

- [ILogger](https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.logging.ilogger?view=dotnet-plat-ext-5.0){:target="_blank"}

__Role:__ To validate all request values provided.

___

### CheckUri

* uriValue

__Returns:__ bool

__Role:__ provides a simple validation check for values passed to the public functions as part of the request body.

__Example Use:__
```csharp
if (RequestHelper.CheckUri(authenticationKey))
{
    log.LogInformation("Valid URL Provided");
}
```
___

### CheckGuid

* idValue

__Returns:__ bool

__Role:__ provides a simple validation check for values passed to the public functions as part of the request body.

__Example Use:__
```csharp
if (!RequestHelper.CheckGuid(applicationId))
{
    log.Error("Invalid GUID Provided.");
}
```
___

### ReportInvalidBody

- [ILogger](https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.logging.ilogger?view=dotnet-plat-ext-5.0){:target="_blank"}
- additions

__Returns:__ [InvalidRequestException](/procfwk/invalidrequestexception)

__Role:__ 

__Example Use:__
```csharp
protected void ReportInvalidBody(ILogger logger)
{
    var msg = "Invalid body.";
    logger.LogError(msg);
    throw new InvalidRequestException(msg);
}
```

___

### ParametersAsObjects

__Returns:__ [Dictionary](https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.dictionary-2){:target="_blank"}

__Role:__ To parse provided worker pipeline parameters and return a dictionary of values to be used by the [pipeline service](/procfwk/services).

__Example Use:__
```csharp
var dictionary = new Dictionary<string, object>();
foreach (var key in PipelineParameters.Keys)
    dictionary.Add(key, PipelineParameters[key]);
return dictionary;
```

___