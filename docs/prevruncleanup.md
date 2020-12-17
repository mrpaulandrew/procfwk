# Previous Execution Run Clean Up

___
[<< Contents](/procfwk/contents) 

___

Assuming the [pipeline already running check](/procfwk/pipelinealreadyrunning) has been passed. The processing framework will next expect the current execution [table](/procfwk/tables) to establish what state the metadata is in, this is a specific check considering if a clean up of the metadata is required.

In the event that a wider platform failure has occurred, meaning the metadata is left in an unexpected state. The framework will attempt to clean up the metadata before asserting if a new or restart of an execution is required. A wider platform failure could include the Azure Functions App failing or the SQL database going offline during a set of worker pipeline executions.

The [stored procedure](/procfwk/storedprocedures) [procfwk].[CheckPreviousExeuction] establishes if an execution run clean up is required. In simple terms this procedure performs the following query against the database:

```sql
SELECT
	*
FROM 
	[procfwk].[CurrentExecution]
WHERE 
	[PipelineStatus] NOT IN 
		(
		'Success',
		'Failed',
		'Blocked',
		'Cancelled'
		) 
	AND [PipelineRunId] IS NOT NULL
	--if using batch executions:
	AND [LocalExecutionId] = @LocalExecutionId;
```

If this query returns results, for example, with a worker pipeline that has a status of 'Running', is the worker actually running? Or did the failure mean the completion status never got provided to the database table.

Using the (metadata captured) pipeline Run Id, the status values are validated for the workers in the result set by performing a one off set of checks within the parent pipeline, and before the execution wrapper [stored procedure](/procfwk/storedprocedures) is called. The actual worker pipeline status values are then updated in the current execution table.

___

The following parent pipeline activity chain snippet shows the clean-up handling using a subset of the infant pipeline to perform the worker [pipeline](/procfwk/pipelines) status checks.

[ ![](/procfwk/activitychain-cleanup.png) ](/procfwk/activitychain-cleanup.png){:target="_blank"}

___