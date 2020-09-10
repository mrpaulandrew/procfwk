## Functions

___
[<< Contents](/ADF.procfwk/contents) 

* [Helpers](/ADF.procfwk/helpers)
* [Execute Pipeline](/ADF.procfwk/executepipeline)
* [Check Pipeline Status](/ADF.procfwk/checkpipelinestatus)
* [Get Error Details](/ADF.procfwk/geterrordetails)
* [Send Email](/ADF.procfwk/sendemail)

___
![Azure Functions Icon](/ADF.procfwk/function.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}
Azure Functions provide the middle ware in the processing framework allowing the orchestration Data Factory pipelines to interact with the worker pipelines or access external resources.

The highly scalable, cheap, serverless compute provides the required customisations to extend the framework and acheive a level of [decoupling](/ADF.procfwk/workerdecoupling) between orchestration resources as well as supporting its own authenticate to Key Vault when needed.

All the Functions within the processing framework are created using:

![Code Icons](/ADF.procfwk/csharpdotnetcore.png)

## Managed Service Identity (MSI)
![MSI](/ADF.procfwk/msi.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}
Enabling the Azure Function App is optional if you want to store worker pipeline [SPN details in Azure Key Vault](/ADF.procfwk/spnhandling).