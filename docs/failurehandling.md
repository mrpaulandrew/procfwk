# Failure Handling

___
[<< Contents](/procfwk/contents) 

___

https://mrpaulandrew.com/2020/07/01/adf-procfwk-v1-8-complete-pipeline-dependency-chains-for-failure-handling/



In the event of a worker pipeline does not complete successfully the processing framework can take several actions and behaviour in different ways according to the configuration of the [properties](/procfwk/properties). At runtime the framework uses the set property values in various locations to establish what to do next, the following outlines each should situation and how the framework could behave.

In the event of a worker pipeline failure...

## Do Nothing


## Stop Processing and Block All Downstream Execution Stages


## Allow Processing to Continue and Only Block Affected Downstream Dependant Worker Pipelines


These behaviours are also repeated using the following configured [properties](/procfwk/properties) where values are set to '1', meaning true.

* UnknownWorkerResultBlocks
* CancelledWorkerResultBlocks

In this context, an unknown worker pipeline status and a cancelled worker pipeline status are also treated as failures.

If these other pipeline status values are set to '0', meaning false the framework will simply accept the outcome and carry on. Then once all execution stages are complete the overall framework run will be accessed as successfully (all workers succeeded) or failed.