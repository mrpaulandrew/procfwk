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

## Release Details

| Version | Overview | Related Blog(s) & Version Details |
|:----:|--------------|--------|
| 1.8.6 |<u>Pipeline Expressions Refactored to Use Variables</u> added, plus:<ul><li>New integration tests created.</li><li>Complete activity chain redrawn in Visio.</li></ul> |Issues:</br>[ADF.procfwk #51](https://github.com/mrpaulandrew/ADF.procfwk/issues/51)<br/>[ADF.procfwk #52](https://github.com/mrpaulandrew/ADF.procfwk/issues/52) |
| 1.8.5 |<u>Execution Precursor</u> added, plus:<ul><li>PowerShell helper to add initial Worker metadata.</li></ul> |[ADF.procfwk v1.8.5 - Execution Precursor](https://mrpaulandrew.com/2020/08/17/adf-procfwk-v1-8-5-execution-precursor/) |
| 1.8.4 |<u>Database Schema Reorganise and Restructuring</u> |[ADF.procfwk v1.8.4 - Database Schema Reorganise and Restructuring](https://mrpaulandrew.com/2020/07/23/adf-procfwk-v1-8-4-database-schema-reorganise-and-restructuring/) |
| 1.8.3 |<u>Bug Fixes from the Community</u>, including:<ul><li>Email alerts sent to blank email addresses due to wrong flow in Child pipeline.</li><li>Worker pipelines cancelled during an execution fail when the framework is restarted due to missing Parent pipeline clean up condition.</li></ul> |Issues:</br>[ADF.procfwk #38](https://github.com/mrpaulandrew/ADF.procfwk/issues/38)<br/>[ADF.procfwk #37](https://github.com/mrpaulandrew/ADF.procfwk/issues/37) |
| 1.8.2 |<u>Optionally Store SPN Details in Azure Key Vault</u> |[ADF.procfwk v1.8.2 - Optionally Store SPN Details in Azure Key Vault](https://mrpaulandrew.com/2020/07/22/adf-procfwk-v1-8-2-optionally-store-spn-details-in-azure-key-vault/) |
| 1.8.1 |<u>Automated Framework Pipeline Testing</u> added, including tests for:<ul><li>A simple grandparent run.</li><li>All types of failure dependency handling.</li><li>Metadata checks when pipelines and staged are disabled.</li><li>No pipeline parameters provided.</li></ul> |Blog Series: <br/><ol><li>[Set up automated testing for Azure Data Factory](https://richardswinbank.net/adf/set_up_automated_testing_for_azure_data_factory)</li><li>[Automate integration tests in Azure Data Factory](https://richardswinbank.net/adf/automate_integration_tests_in_azure_data_factory)</li><li>[Isolated functional tests for Azure Data Factory](https://richardswinbank.net/adf/isolated_functional_tests_for_azure_data_factory)</li><li>[Testing Azure Data Factory in your CI/CD pipeline](https://richardswinbank.net/adf/testing_azure_data_factory_in_your_cicd_pipeline)</li><li>[Unit testing Azure Data Factory pipelines](https://richardswinbank.net/adf/unit_testing_azure_data_factory_pipelines)</li><li>[Calculating Azure Data Factory test coverage](https://richardswinbank.net/adf/calculating_azure_data_factory_test_coverage)</li></ol> |
| 1.8.0 |<u>Complete Pipeline Dependency Chains For Failure Handling</u> added, plus:<ul><li>Clean up of a previous execution run if Workers appear as running.</li><li>New metadata integrity checks.</li><li>Internal get property value function added.</li></ul> |[ADF.procfwk v1.8 - Complete Pipeline Dependency Chains For Failure Handling](https://mrpaulandrew.com/2020/07/01/adf-procfwk-v1-8-complete-pipeline-dependency-chains-for-failure-handling/) |
| 1.7.3 |Data Factory Deployment Updated To Use azure.datafactory.tools  PowerShell Module |[SQLPlayer/azure.datafactory.tools](https://github.com/SQLPlayer/azure.datafactory.tools) |
| 1.7.2 |<u>Pipeline Parameter NULL Handling</u> added, plus:<ul><li>Worker pipelines with a status of 'Running' protected from a new execution start/restart.</li></ul> |[ADF.procfwk v1.7.2 - NULL Pipeline Parameters Handled](https://mrpaulandrew.com/2020/06/22/adf-procfwk-v1-7-2-null-pipeline-parameters-handled/) |
| 1.7.1 |<u>Alerting Check Bug Fix</u> added, plus:<ul><li>Pipeline parameter value size limit removed.</li></ul> |[ADF.procfwk v1.7.1 - Alerting Bug Fix And Pipeline Parameter Size Limit Removed](https://mrpaulandrew.com/2020/06/12/adf-procfwk-v1-7-1-alerting-bug-fix-and-pipeline-parameter-size-limit-removed/) |
| 1.7.0 |<u>Pipleline EMail Alerting</u> added, plus:<ul><li>Send email Function implemented and hardened.</li><li>Handy Notebook updates.</li><li>Activity failure paths improved.</li><li>MIT license and code of conduct added.</li><li>Error table bug fix. Error code attribute; INT to VARCHAR</li></ul> |[ADF.procfwk v1.7 - Pipeline Email Alerting](https://mrpaulandrew.com/2020/06/08/adf-procfwk-v1-7-pipeline-email-alerting/) |
| 1.6.0 |<u>Error Details for Failed Activities Captured</u>, plus:<ul><li>Pipeline parameters used at runtime captured in execution logs.</li><li>Emailing Function added, not yet implemented.</li><li>Unknown Worker outcomes optionally blocks downstream stages.</li><li>Solution housekeeping.</li></ul> |[ADF.procfwk v1.6 - Error Details for Failed Activities Captured](https://mrpaulandrew.com/2020/05/19/adf-procfwk-v1-6-error-details-for-failed-activities-captured/) |
| 1.5.0 |<u>Power BI Dashboard for Framework Executions</u>, plus:<ul><li>Worker Parallelism View.</li><li>Pipeline Run ID now logged.</li><li>Logging Attributes Bug Fix.</li></ul> |[ADF.procfwk v1.5 - Power BI Dashboard for Framework Executions](https://mrpaulandrew.com/2020/05/01/adf-procfwk-v1-5-power-bi-dashboard-for-framework-executions/) |
| 1.4.0 |<u>Enhancements for Long Running Pipelines</u>, plus:<ul><li>Pipeline check status function added.</li><li>Function Data Factory client moved to internal class.</li><li>SQL GETDATE() changed to GETUTCDATE().</li><li>Glossary created, [here](https://github.com/mrpaulandrew/ADF.procfwk/blob/master/Glossary.md).</li><li>Updated database views.</li></ul>  |[ADF.procfwk v1.4 - Enhancements for Long Running Pipelines](https://mrpaulandrew.com/2020/04/20/adf-procfwk-v1-4-enhancements-for-long-running-pipelines/) |
| 1.3.0 |<u>Metadata Integrity Checks</u>, plus: <ul><li>Logical pipeline predecessors.</li><li>Data Factory Powershell deployment script.</li><li>Helper Notebook.</li><li>Database objects renames and solution tidy up.</li></ul> |[ADF.procfwk v1.3 - Metadata Integrity Checks](https://mrpaulandrew.com/2020/04/07/adf-procfwk-v1-3-metadata-integrity-checks/)  |
| 1.2.0 |<u>Execution Restartability</u>, plus: <ul><li>Data Factory annotations and descriptions.</li><li>Database covering indexes.</li><li>Pipeline log status changed from 'Started' to 'Preparing'.</li><li>Pipeline log start date/time now set in child pipeline.</li></ul> |[ADF.procfwk v1.2 - Execution Restartability](https://mrpaulandrew.com/2020/03/24/adf-procfwk-v1-2-execution-restartability/)  |
| 1.1.0 |<u>Service Principal Handling</u> via Metadata, plus: <ul><li>Data Factory table.</li><li>Properties table and view.</li><li>Function body bug fix.</li><li>New sample data.</li></ul> |[ADF.procfwk v1.1 - Service Principal Handling via Metadata](https://mrpaulandrew.com/2020/03/17/adf-procfwk-v1-1-service-principal-handling-via-metadata/) |
| 1.0.0 |Simple <u>framework designed and base compontents built</u>.<br/><ul><li>Part 1 - Design, concepts, service coupling, caveats, problems.</li><li>Part 2 - Database build and metadata.</li><li>Part 3 - Data Factory build.</li><li>Part 4 - Execution, conclusions, enhancements.</li></ul>|Blog Series: <br/>[Creating a Simple Staged Metadata Driven Processing Framework for Azure Data Factory Pipelines](https://mrpaulandrew.com/2020/02/25/creating-a-simple-staged-metadata-driven-processing-framework-for-azure-data-factory-pipelines-part-1-of-4/) |
