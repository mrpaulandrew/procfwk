# Pipelines

___
[<< Contents](/procfwk/contents) / [Data Factory](/procfwk/datafactory)

___

## Grandparent - Environment Setup
![Grandparent Pipeline](/procfwk/grandparent.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 150px;"}
__Role:__ Optional level platform setup, for example, scale up/out compute services ready for the framework to run.

The grandparent level within the processing framework solution is completely optional. It is expected that here higher level platform operations are performed to make the environment ready before the core framework is triggered. This maybe include a set of data ingestion processes.

___

## Parent - Framework Executor
![Parent Pipeline](/procfwk/parent.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 150px;"}
__Role:__ Execution run wrapper and execution stage iterator.

The parent pipeline is primarily used to setup and/or cleanup the next execution run for the framework, depending on the current database [Properties](/procfwk/properties). It runs precursor operations and resets the metadata where required in either new or restart scenarios. 

As a secondary function at this level the parent pipeline initiates the first __ForEach__ activity used to _sequentially_ iterate over [Execution Stages](/procfwk/executionstages). For each iteration the framework will also check for any workers that may have blocked processing due to worker pipeline failures.

Finally, the parent is responsible for getting/setting of the Local Execution ID which is then used throughout all downstream pipelines when making updates to the metadata current execution [table](/procfwk/tables).

___

## Child - Stage Executor
![Child Pipeline](/procfwk/child.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 150px;"}
__Role:__ Scale out triggering of worker pipelines within the execution stage.

The child pipeline is called once per execution stage. It is small in structure and has a simple purpose to hit the second level __ForEach__ activity, this is used to trigger all worker pipelines within the current execution stage _in parallel_. This [Scale Out Processing](/procfwk/scaleoutprocessing) is achieved using the default behaviour for the Data Factory activity.

___

## Infant - Worker Executor
![Infant Pipeline](/procfwk/infant.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 150px;"}
__Role:__ Worker executor, monitor and reporting of the outcome for the single worker pipeline.

Once a worker pipeline has been triggered by the child one infant pipeline per worker is used to handle the execution and monitoring of its run. The infant uses an __Until__ activity to iterate over the status of its given worker pipeline waiting until it completes. Once complete the infant will update the metadata with the relevant status information and error details in the event of a worker failure.

The time between infant check status iterations can be configured via the database [Properties](/procfwk/properties) table.

The infant (ironically) is the largest pipeline and has the most activities within the framework, doing the most work. This is to consistency and controllably deal with the execution of the worker pipelines. From a boiler plate code perspective, it is also the pipeline that gets reused/called the most.

The infant pipeline could be used in isolation in trigger a worker pipeline if required.

____

## Worker
![Worker Pipeline](/procfwk/worker.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 150px;"}
__Role:__ Anything specific to the process needing to be performed.

Worker pipeline internals fall outside the remit of the processing framework. They exist only as items registered within the metadata plus associated parameters (if required). Worker pipelines are expected to contain whatever activities are required for a given process and should not use content from the processing framework metadata database other than the pipeline level parameters provided at runtime.

By design [worker pipelines can be decoupled](/procfwk/workerdecoupling) from the main orchestration pipelines above and live in separate Data Factory resources.
