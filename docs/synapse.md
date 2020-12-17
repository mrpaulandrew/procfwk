# Synapse

___
[<< Contents](/procfwk/contents) / [Orchestrators](/procfwk/orchestrators) / [Orchestrator Types](/procfwk/orchestratortypes)

___
![Synapse Icon](/procfwk/synapse.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}Azure Synapse Analytics and its Intergrate Pipeline capability is one of the primary resources within the processing framework solution used for delivering both the execution of the orchestration [pipelines](/procfwk/pipelines) (Grandparent, Parent, Child, Infant, Utilities) and used to deliver worker pipelines created as modules outside of the processing solution.

In the context of the processing framework Synapse Analytics Intergrate Pipelines operates at the control flow level as one of the [orchestrators](/procfwk/orchestrators) available for a given solution. Data flow level transformtion operations are not handled within the framework. It is expected that dataset level tasks are delivered by the worker pipelines that this framework triggers.

___

<p align="center">
  <img height="150" src="/procfwk/orc-syn-all.png">
</p>

___

Synapse Analytics uses the following common components to deliver the framework execution runs.

* [Linked Services](/procfwk/linkedservices)
* [Datasets](/procfwk/datasets)
* [Pipelines](/procfwk/pipelines)
* [Activities](/procfwk/activities)

___