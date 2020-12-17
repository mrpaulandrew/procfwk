# Services

___
[<< Contents](/procfwk/contents) / [Functions](/procfwk/functions)

___

## Role

Acts as the entry point and basis for all interactions between the  framework and the worker pipelines.

The services concept is used to decouple interactions from the intended orchestrator type and allow future orchestrator types to be included by implementing a new set of service methods. In all cases the below abstract methods will be used for the type provided.

Namespace: __mrpaulandrew.azure.procfwk.Services__.

```csharp
public static PipelineService GetServiceForRequest
    (
    PipelineRequest pr, 
    ILogger logger
    )
{
    if (pr.OrchestratorType == PipelineServiceType.ADF)
        return new AzureDataFactoryService(pr, logger);

    if (pr.OrchestratorType == PipelineServiceType.SYN)
        return new AzureSynapseService(pr, logger);

    throw new InvalidRequestException (
    "Unsupported orchestrator type: " + 
    (pr.OrchestratorType?.ToString() ?? "<null>"));
}
```
___

## Supported Services ([Service Types](/procfwk/servicetype))

* [AzureDataFactoryService](/procfwk/datafactoryservice)
* [AzureSynapseService](/procfwk/synapseservice)

___

## Abstract Methods

* ValidatePipeline
* ExecutePipeline
* CancelPipeline
* GetPipelineRunStatus
* GetPipelineRunActivityErrors

___

## Method Return Types

### PipelineDescription

Properties:

| Property Name | Type |
|------------|-------------|
| PipelineExists | string |
| PipelineName | string |
| PipelineId | string |
| PipelineType | string |
| ActivityCount | int |

___

### PipelineRunStatus

Properties:

| Property Name | Type |
|------------|-------------|
| PipelineName | string |
| RunId | string |
| ActualStatus | string |
| SimpleStatus | string |

The simple status value is resolved internally from the actual status in the return class using a private method and switch statement.

```csharp
string simpleStatus = actualStatus switch
{
    "Queued" => Running,
    "InProgress" => Running,
    "Canceling" => Running, //microsoft typo
    "Cancelling" => Running,
    _ => Complete,
};
return simpleStatus;
```

___

### PipelineFailStatus

Inherits PipelineRunStatus.

The constructor instantiates the FailedActivity list below.

Properties:

| Property Name | Type |
|------------|-------------|
| ResponseCount | int |
| ResponseErrorCount | int |
| FailedActivity | list |

___

### FailedActivity

Internally set properties:

| Property Name | Type |
|------------|-------------|
| ActivityRunId | string |
| ActivityName | string |
| ActivityType | string |
| ErrorCode | string |
| ErrorType | string |
| ErrorMessage | string |

___