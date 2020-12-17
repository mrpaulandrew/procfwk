# Validate Pipeline

___
[<< Contents](/procfwk/contents) / [Functions](/procfwk/functions)

___

## Role

Called as part of the infant [pipeline](/procfwk/pipelines) this Function performs a soft check against the target [orchestrator](/procfwk/orchestrators) to ensure the worker pipeline exists before continuing and attempting to execute the worker.

The soft check ensures the metadata is left in a controlled state instead of the proceeding [execute pipeline](/procfwk/executepipeline) function throwing an execption.

- If the worker is available, its resource ID value will be returned with a PipelineExists value of __true__.

- If the worker isn't available in the target [orchestrator](/procfwk/orchestrators) instance the specific internal function exception is caught and supressed allowing the framework [pipeline](/procfwk/pipelines) to deal with the problem and update the metadata. A PipelineExists value of __false__ will be returned.

Other unexpected exceptions will still be thrown in the usual way.

Reasons for the validation check to fail include:
- The worker pipeline name has been entered incorrectly in the metadata database. This includes spaces in the text field.
- The worker pipeline hasn't yet been deployed to the target [orchestrator](/procfwk/orchestrators) instance.

Namespace: __mrpaulandrew.azure.procfwk__.

## Method

GET, POST

## Body Request

```json
{
"tenantId": "123-123-123-123-1234567",
"applicationId": "123-123-123-123-1234567",
"authenticationKey": "Passw0rd123!",
"subscriptionId": "123-123-123-123-1234567",
"resourceGroupName": "ADF.procfwk",
"orchestratorName": "FrameworkFactory",
"orchestratorType": "ADF",
"pipelineName": "Intentional Error"
}
```

## Return

See [Services](/procfwk/services) return classes.

## Example Output

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

___