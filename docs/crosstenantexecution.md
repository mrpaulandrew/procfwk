# Cross Tenant & Subscription Execution

___
[<< Contents](/procfwk/contents) 

___

During a run of the processing framework worker [pipelines](/procfwk/pipelines) are triggered for execution. These worker pipelines can be deployed to any [orchestrator](/procfwk/orchestrators) resource, anywhere within the Microsoft Azure platform. In addition, a single set of metadata can call out to worker pipelines in multiple [orchestrator](/procfwk/orchestrators) instances. As long as the framework is provided with the following details to authenticate against the target [orchestrator](/procfwk/orchestrators) instance where the worker pipeline can be triggered.

* Tenant Id
* Subscription Id
* Resource Group Name
* Orchestrator Name
* [Orchestrator Type](/procfwk/orchestratortypes)
* Pipeline Name

To further clarify, within the metadata [database](/procfwk/database) these authentication details are connected to a worker pipeline. Meaning, granular authentication to a worker pipeline wherever it is deployed.

[ ![](/procfwk/crosstenantauth.png) ](/procfwk/crosstenantauth.png){:target="_blank"}

For example, the processing framework could be setup in the following ways depending on your requirements:

* Using a single Data Factory or Synapse instance for all framework pipelines and all worker pipelines authenticated with a single service principals.

* Using multiple Data Factory instances, one for framework pipelines and a second for all worker pipelines. The worker factory instance uses a single service principal for all worker pipelines.

* Using a single Synapse instance for all pipelines, but every worker pipeline requires a different service principal to authenticate.

* Using three [orchestrators](/procfwk/orchestrators); one for framework pipelines, one for worker pipelines doing none PII data processing, one for worker pipelines doing PII data processing. Each worker [orchestrator](/procfwk/orchestrators) uses a different set of service principal details that are returned from different Azure Key Vault instances. 

* Using one Data Factory instnace for all framework pipelines, that calls 6x worker Synapse instances in different Azure Subscriptions. Each worker Synapse instance has a different service principal to authenticate against its worker pipelines.

* Using one Data Factory instnace for all framework pipelines in one Azure Tenant, that calls 3x worker Data Factory's all in different Azure Tenants and different Azure Regions. Each worker Data Factory requires localised service principal details for the target worker pipelines on the target tenant.

These are just example scenarios, any other combination of Tenant/Subscription/[orchestrator](/procfwk/orchestrators) is possible. See [service principal handling](/procfwk/spnhandling) for more details on setup and authentication storage options within the framework.

Azure Data Factory and Azure Synapse Analytics are also interchangeable in any of the above statements given the processing frameworks support for different [orchestrator](/procfwk/orchestrators).

A demonstration of using cross tenant worker pipelines is available on YouTube here for Azure Data Factory:

[![YouTube Demo Video](youtubeheader.png)](http://www.youtube.com/watch?v=XdYvJVUWeU4 "Cross Tenant Worker Demo"){:target="_blank"}

___