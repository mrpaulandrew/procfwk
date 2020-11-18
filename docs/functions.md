# Functions (Azure)

___
[<< Contents](/procfwk/contents) 

* [Helpers](/procfwk/helpers)
* [Execute Pipeline](/procfwk/executepipeline)
* [Check Pipeline Status](/procfwk/checkpipelinestatus)
* [Validate Pipeline](/procfwk/validatepipeline)
* [Get Error Details](/procfwk/geterrordetails)
* [Send Email](/procfwk/sendemail)

___
![Azure Functions Icon](/procfwk/function.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}
Azure Functions provide the middle ware in the processing framework allowing the orchestration Data Factory pipelines to interact with the worker pipelines or access external resources.

The highly scalable, cheap, serverless compute provides the required customisations to extend the framework and acheive a level of [decoupling](/procfwk/workerdecoupling) between orchestration resources as well as supporting its own authenticate to Key Vault when needed.

All the Functions within the processing framework are created using:

![Code Icons](/procfwk/csharpdotnetcore.png)

## Managed Service Identity (MSI)
![MSI](/procfwk/msi.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}
Enabling the Azure Function App is optional if you want to store worker pipeline [SPN details in Azure Key Vault](/procfwk/spnhandling).