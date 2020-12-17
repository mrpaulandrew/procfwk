# Orchestrators

___
[<< Contents](/procfwk/contents) 

___

An orchestrator within the context of the processing framework can be defined as an Azure resource used to execute pipelines.

The orchestrators have two key roles when handling these [pipelines](/procfwk/pipelines):

* Housing and running the processing framework pipelines (grandparent, parent, child, infant, utilities).
* Housing and running worker pipelines created as part of the wider data platform solution.

A single orchestrator can also be responsible for both roles housing both framework and worker pipelines.

Currently the processing framework supports the following Azure orchestration services which can be used interchangeably for the roles above.

___

<p align="center">
    <img src="/procfwk/datafactory.png">
    <img src="/procfwk/synapse.png">
</p>

* [Orchestrator Types](/procfwk/orchestratortypes)
  * [Azure Data Factory](/procfwk/datafactory)
  * [Azure Synapse Analytics](/procfwk/synapse)

___

Each orchestrator type uses the following common components.

* [Linked Services](/procfwk/linkedservices)
* [Datasets](/procfwk/datasets)
* [Pipelines](/procfwk/pipelines)
* [Activities](/procfwk/activities)

___