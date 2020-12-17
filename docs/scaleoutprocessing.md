# Scale Out Processing

___
[<< Contents](/procfwk/contents) 

___

![replace](/procfwk/foreach-activity.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}The scaling out (parallel processing) of worker pipelines within an [execution stage](/procfwk/executionstages) is achieved by using the [orchestrators](/procfwk/orchestrators) default behaviour for the ForEach activity. This is set as a batch count value in the activity properties.

When provided with an array of values to iterate over the ForEach activity can do this either sequentially, or by creating parallel threads for all iterations requires.

![foreachparallel](/procfwk/foreach-scaleout.png)

The default behaviour for the ForEach activity is to create a batch of 20 parallel iterations. However, the framework pipelines increase this to the service maximum of 50 parallel iterations within a batch.

- If within an execution stage there are __less__ than 50 worker pipelines to be called they will all be done in parallel and the unallocated iterations within the maximum array (batch) size ignored.
- If within an execution stage there are __more__ than 50 worker pipelines to be called they will be called as soon as space becomes available within the batch.

In all cases the order in which worker pipelines are picked up for execution within a stage is handled by the [orchestrator](/procfwk/orchestrators).

The primary reason within the framework for the child [pipeline](/procfwk/pipelines) is to deliver this scaled out ForEach behaviour for the worker pipelines. The degree of worker parallelism can be seen using the reporting database [view](/procfwk/views), WorkerParallelismOverTime.

___