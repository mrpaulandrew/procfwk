# Validate Pipeline

___
[<< Contents](/procfwk/contents) / [Functions](/procfwk/functions)

___

## Role

Called as part of the infant [pipeline](/procfwk/pipelines) this Function performs a soft check against the target Data Factory to ensure the worker pipeline exists before continuing and attempting to execute the worker.

The soft check ensures the metadata is left in a controlled state instead of the proceeding [execute pipeline](/procfwk/executepipeline) function throwing an execption.

This is done using the 'Microsoft.Azure.Management.DataFactory' client to perform a GET operation of pipelines, providing the resource group, factory and pipeline name to return an instance of the 'PipelineResource' class.

[https://docs.microsoft.com/en-us/dotnet/api/microsoft.azure.management.datafactory.models.pipelineresource](https://docs.microsoft.com/en-us/dotnet/api/microsoft.azure.management.datafactory.models.pipelineresource)

- If the worker is available, its resource ID value will be returned with a PipelineExists value of __true__.

- If the worker isn't available in the target Data Factory instance the internal function exception caugth and supressed allowing the framework Data Factory pipeline to deal with the problem and update the metadata. A PipelineExists value of __false__ will be returned.

Reasons for the validation check to fail include:
- The worker pipeline name has been entered incorrectly in the metadata database. This includes spaces in the text field.
- The worker pipeline hasn't yet been deployed to the target Data Factory instance.

## Example Input

```json
{
"tenantId": "123-123-123-123-1234567",
"applicationId": "123-123-123-123-1234567",
"authenticationKey": "Passw0rd123!",
"subscriptionId": "123-123-123-123-1234567",
"resourceGroup": "ADF.procfwk",
"factoryName": "WorkersFactory",
"pipelineName": "Wait 1"
}
```

## Example Outputs

Worker exists:

```json
{
"PipelineExists": "True",
"PipelineName": "Wait 1",
"PipelineId": "/subscriptions/123-123-123-123-1234567/resourceGroups/ADF.procfwk/providers/Microsoft.DataFactory/factories/WorkersFactory/pipelines/Wait 1",
"PipelineType": "Microsoft.DataFactory/factories/pipelines",
"ActivityCount": "1"
}
```

Worker doesn't exist:

```json
{
"PipelineExists": "False",
"ProvidedPipelineName": "Wait1"
}
```