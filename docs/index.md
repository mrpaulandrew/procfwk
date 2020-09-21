# Welcome to the Orchestrate .procfwk Home Page

This site provides details on the latest version of the processing framework (procfwk) code project, available on GitHub [here](https://github.com/mrpaulandrew/procfwk){:target="_blank"}, as a single source of all information needed to use and support this solution.

Please use the [Contents](/procfwk/contents) page, also available in the side bar, to navigate.

## Code Project Overview

### What is procfwk?

This open source code project delivers a simple metadata driven processing framework for Azure Data Factory (ADF). The framework is made possible by coupling ADF with a SQL Database that houses execution stage and pipeline information that is later called using an Azure Functions App. The execution stage and worker pipeline metadata structure firstly allows stages of dependencies to be executed in sequence. Then secondly, all worker pipelines within a stage to be executed in parallel offering scaled out control flows where no inter-dependencies exist.

The framework is designed to integrate with any existing Data Factory solution by making the lowest level executor a stand alone worker pipeline that is wrapped in a higher level of controlled (sequential) dependencies. This level of abstraction means operationally nothing about the monitoring of the orchestration processes is hidden in multiple levels of dynamic activity calls. Instead, everything from the processing pipeline doing the work (the Worker) can be inspected using out-of-the-box ADF features.

[ ![](/procfwk/overview.png) ](/procfwk/overview.png){:target="_blank"}

This framework can also be used in any Azure Tenant and allows the creation of complex control flows across multiple Data Factory resources and even across Azure Tenant/Subscriptions as well by connecting Service Principal details through metadata to targeted Tenants > Subscriptions > Resource Groups > Data Factory and Pipelines, this offers very granular administration over any data processing components in a given environment from a single point of orchestration.

### Why use procfwk?

If you're not convinced please watch my [YouTube video](https://www.youtube.com/watch?v=rVlc-GBpNnc){:target="_blank"} on why you need a metadata driven processing framework.

## Framework Capabilities

 * Granular metadata control.
 * Metadata integrity checking.
 * Global properties.
 * Complete pipeline dependency chains.
 * Execution restart-ability.
 * Parallel execution.
 * Full execution and error logs.
 * Operational dashboards.
 * Low cost orchestration.
 * Disconnection between framework and Worker pipelines.
 * Cross Tenant/Subscription/Data Factory control flows.
 * Pipeline parameter support.
 * Simple troubleshooting.
 * Easy deployment.
 * Email alerting.
 * Automated testing.
 * Azure Key Vault integration.

## Deployment Steps

For details on how to deploy the processing framework to your Azure Tenant see [Deploying ProcFwk](/procfwk/deployprocfwk).

## Complete Data Factory Activity Chain

[ ![](/procfwk/activitychain-full.png) ](/procfwk/activitychain-full.png){:target="_blank"}
