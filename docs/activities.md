# Activities

___
[<< Contents](/procfwk/contents) / [Data Factory](/procfwk/datafactory)

___

For each level of the framework framework activity chain the __Execute Pipeline__ activity is used to entering into the next level.

The complete activity chain can be viewed via the Visio design file in the solution code repository in GitHub [here](https://github.com/mrpaulandrew/procfwk/blob/master/Images/ADFprocfwk%20Designs.vsdx).

___

## Parent Pipeline

Key activities at this level, reading from left to right:
* First ForEach, parallel execution, used to validation and [clean up](/procfwk/prevruncleanup) a previous execution run.
* Lookup, Execution Wrapper, this activity setups up the next execution for the framework and establishes if this is a new run or a restart using an underlying database [stored procedure](/procfwk/storedprocedure).
* Second ForEach, sequentially,

[ ![](/procfwk/activitychain-parent.png) ](/procfwk/activitychain-parent.png)

___

## Child Pipeline

[ ![](/procfwk/activitychain-child.png) ](/procfwk/activitychain-child.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 150px;"}Key activities at this level, reading from left to right:
* Get Pipeline, lookup, this uses an underlying [stored procedure](/procfwk/storedprocedure) to return a simple array of enabled pipeline Id values from the metadata database current execution [table](/procfwk/tables).
* Execute (worker) Pipelines, ForEach, parallel execution, allows the call to worker pipelines to run using [scaled out](/procfwk/scaleoutprocessing) behaviour through the infant [pipeline](/procfwk/pipelines).

___

## Infant Pipeline

At the infant level, every activity becomes important and used during the normal execution of a given worker pipeline. From left to right:
* The infant gets and sets variables from the metadata database to support authentication against the target worker pipeline. This is done at the infant level to support [cross tenant and subscription authentication](/procfwk/crosstenantexecution). Variables are used to avoid the repeat of activity output expressions throughout the pipeline, especially in the [function](/procfwk/functions) body requests.
* The first function activity hits the target worker 

[ ![](/procfwk/activitychain-infant.png) ](/procfwk/activitychain-infant.png)