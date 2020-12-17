# Functions (Azure)

___
[<< Contents](/procfwk/contents) 

* [Execute Pipeline](/procfwk/executepipeline)
* [Check Pipeline Status](/procfwk/checkpipelinestatus)
* [Validate Pipeline](/procfwk/validatepipeline)
* [Get Error Details](/procfwk/geterrordetails)
* [Cancel Pipeline](/procfwk/cancelpipeline)
* [Send Email](/procfwk/sendemail)

___
![Azure Functions Icon](/procfwk/function.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}
Azure Functions provide the middle ware in the processing framework allowing the orchestration pipelines to interact with the worker pipelines or access external resources.

The highly scalable, cheap, serverless compute provides the required customisations to extend the framework and acheive a level of [decoupling](/procfwk/workerdecoupling) between orchestration resources as well as supporting its own authenticate to Key Vault when needed.

All the Functions within the processing framework are created using:

![Code Icons](/procfwk/csharpdotnetcore.png)

___

## Services

To support the interchangeable use of orchestrators in the processing framework (Azure Data Factor or Azure Synapse Analytics) the Function App's internal classes are setup using a services architecture.

At runtime the abstract class _PipelineService_ is called which inspects the request for the [orchestrator type](/procfwk/orchestratortypes). Given the enumerable value the required [orchestrator](/procfwk/orchestrators) service class is then instantiated.

See [services](/procfwk/services) for more details.

___

## Helpers

Alongside the primary function methods a set of helper classes are used to define return types and support the function requests.

See [helpers](/procfwk/helpers) for more details.

___

## Managed Identity (MSI)
![MSI](/procfwk/msi.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 50px;"}
Enabling the Azure Function App managed identity is optional if you want to store worker pipeline [SPN details in Azure Key Vault](/procfwk/spnhandling).

The MSI could also be used to authenticate against the worker pipelines directly removing the need for the SPN metadata. Although this option is understood, it is not implemented or supported by the framework as it would underpin the [cross Azure tenant](/procfwk/crosstenantexecution) execution support.

___