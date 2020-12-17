# Activities

___
[<< Contents](/procfwk/contents) / [Orchestrators](/procfwk/orchestrators)

___


The complete activity chain can be viewed via the Visio design file in the solution code repository in GitHub [here](https://github.com/mrpaulandrew/procfwk/blob/master/Images/ADFprocfwk%20Designs.vsdx). Otherwise this page offers a simple overview of the key activities in each level of the processing framework.

The processing framework chain of operations uses the __Execute Pipeline__ activity to enter into the next lower level pipeline; grandparent > parent > child > infant. This is the only ocasion where the execution pipeline activity is used and can be considered a good marker to separate the generational levels of the framework activities.

___

## Parent Pipeline:

Key activities at this level, reading from left to right in the image below:
* Clean Up Previous Run (ForEach), parallel execution, used to validation and [clean up](/procfwk/prevruncleanup) a previous execution run.
* Execution Wrapper (Lookup), this activity setups up the next execution for the framework and establishes if this is a new run or a restart using an underlying database [stored procedure](/procfwk/storedprocedure).
* Execute Stage (ForEach), sequentially, as the name of the activity suggests, this second ForEach within the parent pipeline iterates over all enabled [execution stages](/procfwk/executionstages) created within the stage metadata table.

[ ![](/procfwk/activitychain-parent.png) ](/procfwk/activitychain-parent.png)

___

## Child Pipeline:

[ ![](/procfwk/activitychain-child.png) ](/procfwk/activitychain-child.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 150px;"}Key activities at this level, reading from left to right:
* Get Pipeline (Lookup), this uses an underlying [stored procedure](/procfwk/storedprocedure) to return a simple array of enabled pipeline Id values from the metadata database current execution [table](/procfwk/tables).
* Execute (worker) Pipelines (ForEach), parallel execution, allows the call to worker pipelines to run using [scaled out](/procfwk/scaleoutprocessing) behaviour through the infant [pipeline](/procfwk/pipelines).

As the child pipeline is very small in terms of operations and purpose there aren't any other noteworthy activities to call out.

___

## Infant Pipeline:

At the infant level, every activity becomes important and used during the normal execution of a given worker pipeline. From left to right in the image below:
* The infant gets and sets variables from the metadata database to support authentication when calling the target worker pipeline (wherever it may be). This is done at the infant level to support [cross tenant and subscription authentication](/procfwk/crosstenantexecution). Variables are used to avoid the repeat of activity output expressions throughout the pipeline, especially in the [function](/procfwk/functions) body requests.
* The first function activity hits the target worker to trigger an execution. This function returns once the target worker has an 'In Progress' status.
* Once the worker is in progress the infant starts its until activity, iterating over the second function activity, getting the worker pipeline status and waiting if it remains incomplete. The worker state variable is used as the break condition for the until activity as well as if condition checker, before a wait activity is used. Simply put, while the worker pipeline is still in progress, the infant will wait and check again. The duration of the wait is configurable in the database [properties](/procfwk/properties) table.
* After the target worker pipeline completes it's outcome status is captured and returned to the database. If the worker pipeline has failed. The error messages will also be passed to the database and recorded in the error log table.
* Finally, the infant pipeline will check for any required email alerts depending on the outcome of the worker pipeline and use a function activity to [send the email](/procfwk/sendemail).

[ ![](/procfwk/activitychain-infant.png) ](/procfwk/activitychain-infant.png)

___