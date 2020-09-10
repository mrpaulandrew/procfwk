# Framework Restart

___
[<< Contents](/ADF.procfwk/contents) 

___

Following the failure of a worker pipeline you may wish to re-run or restart the framework execution. In either case this can simply be handling via the Data Factory monitoring portal by selecting 're-run' on the applicable grandparent or parent pipeline that currently has a status of failed.

The [property](/ADF.procfwk/properties) __OverideRestart__ is also key to what the framework does when the re-run operation is called.

* If the property is set to '0', meaning false (which is the default), the framework will inspect the current execution [table](/ADF.procfwk/tables) and remove the pipeline status for any worker that didn't complete successfully. Then restart processing from the first incomplete execution stage. All worker [pipelines](/ADF.procfwk/pipelines) that did complete successfully will be left alone and not re-run.

    In the event of a restart the same LocalExecutionId value will be used allowing a complete log of the execution to be viewed with start and end date time values stanning all attempts to complete until done successfully for all worker.

* If the property is set to '1', meaning true. The framework will ignore any content in the current execution table. If present it will simply be moved (archived) to the execution log table. The framework will then create a new execution run assuming nothing about any previous failures.

