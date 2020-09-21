# Cross Tenant & Subscription Execution

___
[<< Contents](/procfwk/contents) 

___

During execution of the processing framework worker [pipelines](/procfwk/pipelines) are triggered for execution. These worker pipelines can be deployed to any Data Factory resource, anywhere within the Microsoft Azure platform. In addition, a single set of metadata can call out to worker pipelines in multiple Data Factory instances. As long as the framework is provided with the following details to authenticate against the taraget Data Factory instance the worker pipeline can be triggered.

* Tenant Id
* Subscription Id
* Resource Group Name
* Data Factory Name
* Pipeline Name

To further clarify, within the metadata [database](/procfwk/database) these authentication details are connected to a worker pipeline. Meaning, granular authentication to a worker pipeline wherever it is deployed.

[ ![](/procfwk/crosstenantauth.png) ](/procfwk/crosstenantauth.png){:target="_blank"}

For example, the processing framework could be setup in the following ways depending on your requirements:

* Using a single Data Factory instance for all framework pipelines and all worker pipelines authenticated with a single service principals.

* Using multiple Data Factory instances, one for framework pipelines and a second for all worker pipelines. The worker factory instance uses a single service principal for all worker pipelines.

* Using a single Data Factory instance for all pipelines, but every worker pipeline requires a different service principal to authenticate.

* Using three Data Factory's; one for framework pipelines, one for worker pipelines doing none PII data processing, one for worker pipelines doing PII data processing. Each worker Data Factory uses a different set of service principal details that are returned from different Azure Key Vault instances. 

* Using one Data Factory instnace for all framework pipelines, that calls 6x worker Data Factory's in different Azure Subscriptions. Each worker Data Factory has a different service principal to authenticate against its worker pipelines.

* Using one Data Factory instnace for all framework pipelines in one Azure Tenant, that calls 3x worker Data Factory's all in different Azure Tenants and different Azure Regions. Each worker Data Factory requires localised service principal details for the target worker pipelines on the target tenant.

These are just example scenarios, any other combination of Tenant/Subscription/Data Factory is possible. See [service principal handling](/procfwk/spnhandling) for more details on setup and authentication storage options within the framework.

A demonstration of using cross tenant worker pipelines is available on YouTube here:

[![YouTube Demo Video](youtubeheader.png)](http://www.youtube.com/watch?v=XdYvJVUWeU4 "Cross Tenant Worker Demo"){:target="_blank"}