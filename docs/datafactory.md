# Data Factory

___
[<< Contents](/procfwk/contents) 

* [Linked Services](/procfwk/linkedservices)
* [Datasets](/procfwk/datasets)
* [Pipelines](/procfwk/pipelines)
* [Activities](/procfwk/activities)

___
![Data Factory Icon](/procfwk/datafactory.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}
Azure Data Factory is the primary resource within the processing framework solution for delivering both the execution of orchestration [pipelines](/procfwk/pipelines) (Grandparent, Parent, Child, Infant) used to deliver this framework as well as worker pipelines created outside of the processing solution.

In the context of the processing framework Data Factory operates at the control flow level as an orchestrator for a given solution. Data flow level transformtion operations are not handled within the framework. It is expected that dataset level tasks are delivered by the worker pipelines that this framework executes.
