# ADF.procfwk

![alt text](https://mrpaulandrew.files.wordpress.com/2020/07/repo-image-1.png "ADF.procfwk Icon")

## Code Project Overview

This open source code project delivers a simple metadata driven processing framework for Azure Data Factory (ADF). The framework is made possible by coupling ADF with an Azure SQL Database that houses execution stage and pipeline information that is later called using an Azure Functions App. The parent/child metadata structure firstly allows stages of dependencies to be executed in sequence. Then secondly, all pipelines within a stage to be executed in parallel offering scaled out control flows where no inter-dependencies exist.

The framework is designed to integrate with any existing Data Factory solution by making the lowest level executor a stand alone Worker pipeline that is wrapped in a higher level of controlled (sequential) dependencies. This level of abstraction means operationally nothing about the monitoring of orchestration processes is hidden in multiple levels of dynamic activity calls. Instead, everything from the processing pipeline doing the work (the Worker) can be inspected using out-of-the-box ADF features.

This framework can also be used in any Azure Tenant and allow the creation of complex control flows across multiple Data Factory resources by connecting Service Principal details through metadata to targeted Subscriptions &gt; Resource Groups &gt; Data Factory's and Pipelines, this offers very granular administration over data processing components in a given environment.

## Framework Features

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

[ADFprocfwk.com](http://ADFprocfwk.com/)

## Complete Data Factory Activity Chain

![alt text](https://mrpaulandrew.files.wordpress.com/2020/09/activity-chain.png "ADF.procfwk Icon")

## Contributors

| Who | Details |
|------------|-------------|
|Paul Andrew |[@mrpaulandrew](https://twitter.com/mrpaulandrew)<br/>[mrpaulandrew.tech](https://mrpaulandrew.tech)|
|Kamil Nowinski |[@NowinskiK](https://twitter.com/NowinskiK)<br/>[sqlplayer.net](https://sqlplayer.net)|
|Richard Swinbank |[@RichardSwinbank](https://twitter.com/RichardSwinbank)<br/>[richardswinbank.net](https://richardswinbank.net/)|
|Niall Langley |[@NiallLangley](https://twitter.com/NiallLangley)<br/>[github.com/NJLangley](https://github.com/NJLangley)|

## Issues

If you've found a bug or have a new feature request please log the details using the repository issues.

Go to... [Issues](https://github.com/mrpaulandrew/ADF.procfwk/issues)

## Projects
Go to... [External Requests](https://github.com/mrpaulandrew/ADF.procfwk/projects/2)

Go to... [Internal Backlog](https://github.com/mrpaulandrew/ADF.procfwk/projects/1)

## Glossary

Go to... [Glossary](https://github.com/mrpaulandrew/ADF.procfwk/blob/master/Glossary.md)

## Resources and Content

| ![alt text](https://mrpaulandrew.files.wordpress.com/2020/03/azure-square-logo.png?w=75 "Blog Icon") | Blogs |[mrpaulandrew.com/ADF.procfwk](https://mrpaulandrew.com/category/azure/data-factory/adf-procfwk/)|
|:----:|:----:|:----:|
| ![alt text](https://mrpaulandrew.files.wordpress.com/2018/11/github-icon.png?w=75 "GitHub Icon") | **GitHub** |**[github.com/mrpaulandrew/ADF.procfwk](https://github.com/mrpaulandrew/ADF.procfwk)**  |
| ![alt text](https://mrpaulandrew.files.wordpress.com/2020/03/twitterlogo.png?w=75 "Twitter Icon") | **Twitter** |**[#ADFprocfwk](https://twitter.com/search?q=%23ADFprocfwk&amp;src=hashtag_click)** |
| ![alt text](https://mrpaulandrew.files.wordpress.com/2020/06/youtube-icon.png?w=75 "YouTube Icon") | **Vlogs** |**[youtube.com/c/mrpaulandrew](https://www.youtube.com/c/mrpaulandrew)** |
