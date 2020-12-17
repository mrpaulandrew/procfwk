# Orchestrator Types

___
[<< Contents](/procfwk/contents) / [Orchestrators](/procfwk/orchestrators)

___

The processing framework supports the use of both common pipeline orchestration services within Azure:

* [Azure Data Factory](/procfwk/datafactory)
* [Azure Synapse Analytics](/procfwk/synapse)

When implementing the processing framework it is designed so each orchestrator type can be completely interchangeable in terms of the [orchestrators](/procfwk/orchestrators) roles.

The key to this handling is controlled through the [procfwk].[Orchestrators] database [table](/procfwk/tables) where all orchestration services need to be registered. The table attribute __OrchestratorType__ is pivital in how the framework handles and calls pipelines for each service.

| Value | Orchestration Service |
|:------------:|-------------|
| ADF | [Azure Data Factory](/procfwk/datafactory) |
| SYN | [Azure Synapse Analytics](/procfwk/synapse) |

When implemented its possible for framework [pipelines](/procfwk/pipelines) to be housed in [Azure Data Factory](/procfwk/datafactory), with worker [pipelines](/procfwk/pipelines) running in [Azure Synapse Analytics](/procfwk/synapse) and vice versa. Or, having all pipelines housed within a single orchestration service. This includes support for [cross tenant and subscription execution](/procfwk/crosstenantexecution).

The only restriction is that all framework pipelines (Grandparent, Parent, Child, Infant and Utilities) reside within the same orchestration service and are identified by the orchestrators database [table](/procfwk/tables) using the 'IsFrameWorkOrchestrator' attribute.

## Interchangeable Orchestrator Types

The following 6 different orchestrator setups supported by the processing framework in terms of the [orchestrators role](/procfwk/orchestrators) and pipeline location. 

Using [batch executions](/procfwk/executionbatches) offers theorical overlap for framework pipelines calling a single metadata database. However, this is not currently supported and has not been tested.

To ensure [metdata integrity](/procfwk/metadataintegritychecks), a new check and [database](/procfwk/database) contraint exists to ensure within the orchestrators table the attribute __IsFrameworkOrchestrator__ is always set of only one orchestrator entry.

___

<p align="center">
  <img height="150" src="/procfwk/orc-adf-all.png">
</p>

___

![Drivers in ADF](/procfwk/orc-adf-driver.png){:style="float: left;width: 200px;"}![Arrow](/procfwk/arrow-grey.png)![Workers in ADF](/procfwk/orc-adf-worker.png){:style="float: right;width: 200px;"}

___

![Drivers in ADF](/procfwk/orc-adf-driver.png){:style="float: left;width: 200px;"}![Arrow](/procfwk/arrow-grey.png)![Workers in SYn](/procfwk/orc-syn-worker.png){:style="float: right;width: 200px;"}

___

<p align="center">
  <img height="150" src="/procfwk/orc-syn-all.png">
</p>

___

![Drivers in SYN](/procfwk/orc-syn-driver.png){:style="float: left;width: 200px;"}![Arrow](/procfwk/arrow-grey.png)![Workers in SYN](/procfwk/orc-syn-worker.png){:style="float: right;width: 200px;"}

___

![Drivers in SYN](/procfwk/orc-syn-driver.png){:style="float: left;width: 200px;"}![Arrow](/procfwk/arrow-grey.png)![Workers in ADF](/procfwk/orc-adf-worker.png){:style="float: right;width: 200px;"}

___