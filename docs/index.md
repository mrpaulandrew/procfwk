# Welcome to the ADF.procfwk Documentation Home Page

This site provides details on the latest version of the processing framework code project as a single source of all information needed to implement this solution in your Azure data platform environment.

Please use the [Contents](/ADF.procfwk/contents) page, also available in the side bar, to navigate the pages of information available for this project.

## Code Project Overview

This open source code project delivers a simple metadata driven processing framework for Azure Data Factory (ADF). The framework is made possible by coupling ADF with an Azure SQL Database that houses execution stage and pipeline information that is later called using an Azure Functions App. The parent/child metadata structure firstly allows stages of dependencies to be executed in sequence. Then secondly, all pipelines within a stage to be executed in parallel offering scaled out control flows where no inter-dependencies exist.

The framework is designed to integrate with any existing Data Factory solution by making the lowest level executor a stand alone Worker pipeline that is wrapped in a higher level of controlled (sequential) dependencies. This level of abstraction means operationally nothing about the monitoring of orchestration processes is hidden in multiple levels of dynamic activity calls. Instead, everything from the processing pipeline doing the work (the Worker) can be inspected using out-of-the-box ADF features.

![alt text](https://mrpaulandrew.files.wordpress.com/2020/07/repo-image-1.png "ADF.procfwk Icon")

This framework can also be used in any Azure Tenant and allow the creation of complex control flows across multiple Data Factory resources by connecting Service Principal details through metadata to targeted Subscriptions &gt; Resource Groups &gt; Data Factory's and Pipelines, this offers very granular administration over data processing components in a given environment.

If your not convinced please watch my [YouTube video](https://www.youtube.com/watch?v=rVlc-GBpNnc) on why you need a metadata driven processing framework.

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
 * Cross Data Factory control flows.
 * Pipeline parameter support.
 * Simple troubleshooting.
 * Easy deployment.
 * Email alerting.
 * Automated testing.
 * Azure Key Vault integration.

## Complete Data Factory Activity Chain

![alt text](https://mrpaulandrew.files.wordpress.com/2020/09/activity-chain.png "ADF.procfwk Icon")