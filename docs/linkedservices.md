# Linked Services

___

[<< Contents](/procfwk/contents) / [Orchestrators](/procfwk/orchestrators)

___
![Linked Service Icon](/procfwk/linkedservice.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}The processing framework only requires two linked service connections giving the [orchestrator](/procfwk/orchestrators) access to the SQL [database](/procfwk/database) and the Azure [Functions](/procfwk/functions) App. Both can then optional be used with a third linked service connection to Azure Key Vault (which is recommended).

For more granular security models you could use Function level key instead of the top level Function App service key. In which case, more linked service connection maybe required per Function activity request. Unless you wish to handle this dynamically. The framework doesn't have a specific requirement.

Depending on your preferred setup the default, hosted or tailored integration runtime (IR) can be used for these linked service. The framework doesn't have a specific requirement for the IR. Only that connectivity is possible.

## Linked Service Typical Setup

[ ![](/procfwk/linkedservice-connections.png) ](/procfwk/linkedservice-connections.png)

___