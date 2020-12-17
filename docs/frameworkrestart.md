# Framework Restart

___
[<< Contents](/procfwk/contents) 

___

Following the failure of a worker pipeline and subsequent execution run you may wish to re-run or restart the framework execution from the grandparent or parent pipelines. In either case this can be done via the [orchestrators](/procfwk/orchestrators) monitoring portal by selecting 're-run' on the applicable pipeline (that currently has a status of failed).

The [property](/procfwk/properties) __OverideRestart__ is key to what the framework does when the re-run operation is called.

## OverideRestart: 0

If the property is set to '0', meaning false (which is the default), the framework will inspect the current execution [table](/procfwk/tables) and remove the pipeline status for any worker that didn't complete successfully. Then restart processing from the first incomplete execution stage. All worker [pipelines](/procfwk/pipelines) that did complete successfully will be left alone and not re-run.

In the event of a restart the same LocalExecutionId value will be used allowing a complete log of the execution to be viewed with start and end date time values stanning all attempts to complete until done successfully for all worker.

## OverideRestart: 1

If the property is set to '1', meaning true. The framework will ignore any content in the current execution table. If present it will simply be moved (archived) to the execution log table. The framework will then create a new execution run knowing nothing about the previous failure.


The framework restart-ability is established and supported in conjunction with the [failure handling](/procfwk/failurehandling) configuration.

___
