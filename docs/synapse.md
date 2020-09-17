# Synapse

___
[<< Contents](/procfwk/contents) 

___
![Synapse Icon](/procfwk/synapse.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}
Once Synapse has been made GA work will be done to support both Data Factory pipelines and Synapse Orchestrate pipelines in an interchangeable way.

Currently support is limited as the Synapse .Net SDK does not include classes for the pipelines. This means the framework functions cannot call and execute worker pipelines created in Synapse. For more detail please review the following blog post:

[https://mrpaulandrew.com/2020/06/03/adf-procfwk-and-azure-synapse-orchestrate-preview-and-limitations/](https://mrpaulandrew.com/2020/06/03/adf-procfwk-and-azure-synapse-orchestrate-preview-and-limitations/)