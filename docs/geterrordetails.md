# Get Error Details

___
[<< Contents](/procfwk/contents) / [Functions](/procfwk/functions)

___

## Role

In the event of a worker [pipeline](/procfwk/pipelines) failure this function will use the [orchestrators](/procfwk/orchestrators) activity run data to return the error messages presented for all activites with a failure status.

The output and array of error details is then provided to the [database](/procfwk/database) and captured in the error log [table](/procfwk/tables).

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
"pipelineName": "Intentional Error",
"runId": "123-123-123-123-1234567"
}
```

## Return

See [Services](/procfwk/services) return classes.

## Example Output

```json
{
    "ResponseCount": 3,
    "ResponseErrorCount": 2,
    "Errors": [
        {
            "ActivityRunId": "5b8feadf-8400-4c52-b416-96842c97141a",
            "ActivityName": "Raise Errors or Not",
            "ActivityType": "IfCondition",
            "ErrorCode": "ActionFailed",
            "ErrorType": "UserError",
            "ErrorMessage": "Activity failed because an inner activity failed"
        },
        {
            "ActivityRunId": "df7b1650-46a7-4d4d-b78c-dfd96660f836",
            "ActivityName": "Call Fail Procedure",
            "ActivityType": "SqlServerStoredProcedure",
            "ErrorCode": "2402",
            "ErrorType": "UserError",
            "ErrorMessage": "Execution fail against sql server. Sql error number: 50000. Error Message: The Stored Procedure intentionally failed."
        }
    ],
    "PipelineName": "Intentional Error",
    "RunId": "1ec80192-fd68-484c-ba84-21e397fd367a",
    "ActualStatus": "Failed",
    "SimpleStatus": "Complete"
}
```

___