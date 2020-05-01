# ADF.procfwk

![alt text](https://mrpaulandrew.files.wordpress.com/2020/03/adfprocfwk-icon.png "ADF.procfwk Icon")

## Code Project Overview

This open source code project delivers a simple metadata driven processing framework for Azure Data Factory (ADF). The framework is delivered by coupling ADF with an Azure SQL Database that houses execution stage and pipeline information that is later called using an Azure Functions App. The parent/child metadata structure firstly allows stages of dependencies to be executed in sequence. Then secondly, all pipelines within a stage to be executed in parallel offering scaled out control flows where no inter-dependencies exist for a given stage.

The framework is designed to integrate with any existing Data Factory solution by making the lowest level executor a stand alone processing pipeline that is wrapped in a higher level of controlled (sequential) dependencies. This level of abstraction means operationally nothing about the monitoring of orchestration processes is hidden in multiple levels of dynamic activity calls. Instead, everything from the processing pipeline doing the work can be inspected using out-of-the-box ADF features.

This framework can also be used in any Azure Tenant and allow the creation of complex control flows across multiple Data Factory resources by connecting Service Principal details to targeted Subscriptions > Resource Groups > Data Factory's and Pipelines, this offers very granular administration over data processing components in a given environment.

 ## Authors

| Who | Details |
|------------|-------------|
|Paul Andrew |[@mrpaulandrew](https://twitter.com/mrpaulandrew)<br/>[paul@mrpaulandrew.com](mailto:paul@mrpaulandrew.com)<br/>[https://mrpaulandrew.tech](https://mrpaulandrew.tech)|

## Development Backlog
[Go to GitHub Kanban board...](https://github.com/mrpaulandrew/ADF.procfwk/projects/1)

## Glossary

[Go to Glossary...](https://github.com/mrpaulandrew/ADF.procfwk/blob/master/Glossary.md)

## Resources and Content

| ![alt text](https://mrpaulandrew.files.wordpress.com/2020/03/azure-square-logo.png?w=75 "Blog Icon") | Blogs |[mrpaulandrew.com/ADF.procfwk](https://mrpaulandrew.com/category/azure/data-factory/adf-procfwk/)|
|:----:|:----:|:----:|
| ![alt text](https://mrpaulandrew.files.wordpress.com/2018/11/github-icon.png?w=75 "GitHub Icon") | **GitHub** |**[github.com/mrpaulandrew/ADF.procfwk](https://github.com/mrpaulandrew/ADF.procfwk)**  |
| ![alt text](https://mrpaulandrew.files.wordpress.com/2020/03/twitterlogo.png?w=75 "Twitter Icon") | **Twitter** |**[#ADFprocfwk](https://twitter.com/search?q=%23ADFprocfwk&amp;src=hashtag_click)** |

## Release Details

| Version | Overview | Related Blog(s) & Release Notes |
|:----:|--------------|--------|
| 1.5 |<u>Power BI Dashboard for Framework Executions</u>, plus:<ul><li>Worker Parallelism View.</li><li>Pipeline Run ID now logged.</li><li>Logging Attributes Bug Fix.</li></ul> |[ADF.procfwk v1.5 - Power BI Dashboard for Framework Executions](https://mrpaulandrew.com/2020/05/01/adf-procfwk-v1-5-power-bi-dashboard-for-framework-executions/) |
| 1.4 |<u>Enhancements for Long Running Pipelines</u>, plus:<ul><li>Pipeline check status function added.</li><li>Function Data Factory client moved to internal class.</li><li>SQL GETDATE() changed to GETUTCDATE().</li><li>Glossary created, [here](https://github.com/mrpaulandrew/ADF.procfwk/blob/master/Glossary.md).</li><li>Updated database views.</li></ul>  |[ADF.procfwk v1.4 - Enhancements for Long Running Pipelines](https://mrpaulandrew.com/2020/04/20/adf-procfwk-v1-4-enhancements-for-long-running-pipelines/) |
| 1.3 |<u>Metadata Integrity Checks</u>, plus: <ul><li>Logical pipeline predecessors.</li><li>Data Factory Powershell deployment script.</li><li>Helper Notebook.</li><li>Database objects renames and solution tidy up.</li></ul> |[ADF.procfwk v1.3 - Metadata Integrity Checks](https://mrpaulandrew.com/2020/04/07/adf-procfwk-v1-3-metadata-integrity-checks/)  |
| 1.2 |<u>Execution Restartability</u>, plus: <ul><li>Data Factory annotations and descriptions.</li><li>Database covering indexes.</li><li>Pipeline log status changed from 'Started' to 'Preparing'.</li><li>Pipeline log start date/time now set in child pipeline.</li></ul> |[ADF.procfwk v1.2 - Execution Restartability](https://mrpaulandrew.com/2020/03/24/adf-procfwk-v1-2-execution-restartability/)  |
| 1.1 |<u>Service Principal Handling</u> via Metadata, plus: <ul><li>Data Factory table.</li><li>Properties table and view.</li><li>Function body bug fix.</li><li>New sample data.</li></ul> |[ADF.procfwk v1.1 - Service Principal Handling via Metadata](https://mrpaulandrew.com/2020/03/17/adf-procfwk-v1-1-service-principal-handling-via-metadata/) |
| 1.0 |Simple <u>framework designed and base compontents built</u>.<br/><br/><ul><li>Part 1 - Design, concepts, service coupling, caveats, problems.</li><li>Part 2 - Database build and metadata.</li><li>Part 3 - Data Factory build.</li><li>Part 4 - Execution, conclusions, enhancements.</li></ul>|[Creating a Simple Staged Metadata Driven Processing Framework for Azure Data Factory Pipelines](https://mrpaulandrew.com/2020/02/25/creating-a-simple-staged-metadata-driven-processing-framework-for-azure-data-factory-pipelines-part-1-of-4/) |