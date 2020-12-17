# Pipeline Run Request

___
[<< Contents](/procfwk/contents) / [Functions](/procfwk/functions) / [Helpers](/procfwk/helpers)

___

## Inherits

- [Pipeline Request](/procfwk/pipelinerequest)

## Role

To extend the base class [Pipeline Request](/procfwk/pipelinerequest) by including and validating additional values required for interaction with the worker pipelines where other specific properties are used.

Namespace: __mrpaulandrew.azure.procfwk.Helpers__.

## Properties

| Property Name | Type |
|------------|-------------|
| RunId | string |

## Fields

| Name | Type |
|------------|-------------|
| RecursivePipelineCancel | string |
| ActivityQueryStart | DateTime |
| ActivityQueryEnd | DateTime |

## Methods

### Validate

- [ILogger](https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.logging.ilogger?view=dotnet-plat-ext-5.0){:target="_blank"}

__Role:__ To validate all request values provided.

___