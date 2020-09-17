# Pipelines

___
[<< Contents](/ADF.procfwk/contents) / [Data Factory](/ADF.procfwk/datafactory)

___

## Grandparent
![Grandparent Pipeline](/ADF.procfwk/grandparent.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 150px;"}
__Role:__ Optional level platform setup.

The grandparent level within the ADFprocfwk solution is completely optional. It is expected that here higher level platform operations are performed to make the environment ready before the core framework is triggered. For example, scaling up compute resources.
## Parent - Framework Executor
![Parent Pipeline](/ADF.procfwk/parent.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 150px;"}
__Role:__ Execution run wrapper and execution stage iterator.

The parent pipeline is primarily used to setup and/or cleanup the next execution run for the framework, depending on the current database [Properties](/ADF.procfwk/properties). It runs precursor operations and resets the metadata where required in either new or restart scenarios. 

As a secondary function at this level the parent pipeline initiates the first __ForEach__ activity used to _sequentitally_ iterate over [Execution Stages](/ADF.procfwk/executionstages). For each iteration the framework will also check for any workers that may have blocked processing due to pipeline failures.

Finally, the parent is responsible for getting/setting of the Local Execution ID which is then used through all downstream pipelines when making updates to the current execution [table](/ADF.procfwk/tables).

## Child - Stage Executor
![Child Pipeline](/ADF.procfwk/child.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 150px;"}
__Role:__ Scale out triggering of worker pipelines within the execution stage.

The child pipeline is called once per execution stage and performs the second level __ForEach__ activity, this time used to trigger all worker pipelines within the current execution stage _in parallel_. This [Scale Out Processing](/ADF.procfwk/scaleoutprocessing) is achieved using the default behaviour for the Data Factory activity.
## Infant - Worker Executor
![Infant Pipeline](/ADF.procfwk/infant.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 150px;"}
__Role:__ Worker executor, monitor and reporting of the outcome for the single worker pipeline.

Once a worker pipeline has been triggered by the child one infant pipeline per worker is used to handle and monitor its execution. The infant will use an __Until__ activity to iterate over the status of its given worker pipeline waiting until it completes. Once complete the infant will update the metadata with the relevant status information and error details in the event of a worker failure.

The time between infant check status iterations can be configured via the database [Properties](/ADF.procfwk/properties) table.
## Worker
![Worker Pipeline](/ADF.procfwk/worker.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 150px;"}
__Role:__ Anything specific to the process needing to be performed.

Worker pipeline internals fall outside the remit of the processing framework. They exist only as items registered within the metadata plus associated parameters (if required). Worker pipelines are expected to contain whatever activities are required for a given process and should not use content from the ADFprocfwk metadata database other than the pipeline level parameters provided at runtime.

By design [worker pipelines can be decoupled](/ADF.procfwk/workerdecoupling) from the main orchestration pipelines above and live in separate Data Factory resources.
