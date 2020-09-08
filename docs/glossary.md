# ADF.procfwk

[<<< Back to ReadMe](https://github.com/mrpaulandrew/ADF.procfwk/blob/master/README.md)

![alt text](https://mrpaulandrew.files.wordpress.com/2020/03/adfprocfwk-icon.png "ADF.procfwk Icon")

## Glossary

| Term | Explanation and Context |
|:----:|--------------|
| PaaS |Platform as a Service |
| Framework |A collection of resources that operate as a single structure to support a system. |
| Metadata |Data the represents other processes and information about how a solution is going to be controlled by the framework. |
| Azure Data Factory |The Microsoft PaaS offering used for solution orchestration and the primary resource used to deliver the metadata driven processing framework. |
| Azure SQLDB |The Microsoft PaaS relational database offering used to house the framework metadata. |
| Azure Function |The serverless executable code used by the framework to perform discrete and repeatable processes using simple HTTP requests. |
| Azure Function App |The Microsoft Paas offering the represents the application used to house Azure Functions. |
| ADF |An acronym for Azure Data Factory.  |
| procfwk |An acronym to represent the Processing Framework solution delivered by the code project. |
| Linked Service |A component of Azure Data Factory used as an endpoint connection allowing Data Factory to authenticate with other services. |
| Dataset |A component of Azure Data Factory used to define the input, output or means in which another service should be used. A Dataset requires a Linked Service to authenticate. |
| Activity |A component of Azure Data Factory tailored to the requirements of a given operation or task. An Activity may use Datasets and Linked Service as part of its definition. |
| Pipeline |A component of Azure Data Factory used as a logic housing for groups of Activities need to perform an operation. |
| Trigger |A component of Azure Data Factory used to perform execution of Pipelines at defined points or schedules. |
| ForEach |A concept used to represent an iterative process but also a named Activity within Azure Data Factory with special features that mean all iteration instants can be called either in parallel or sequentially. |
| Until |A concept used to represent an iterative process that will continue until a logical condition is met. Until is also a named Activity within Azure Data Factory delivering the same capability as its intended concept. |
| Stage |A set of or just one process that needs to be executed by the metadata driven framework. When multiple stages are defined, they will be executed sequentially and it is expected that stages will form a chain of upstream and downstream dependencies.  |
| Worker |A pipeline created in ADF to house custom code and activities doing whatever you require for your solution. The Worker pipeline is then registered in the metadata for a processing stage that tells the Child pipeline what it needs to go and call. |
| Grandparent |The pipeline used within Azure Data Factory to optionally bootstrap any wider processes before calling the main processing framework pipeline. |
| Parent |The pipeline used to bootstrap the orchestration framework in perform the first level ForEach calls in sequence for the metadata stages. |
| Child |The pipeline used to execute Worker pipelines within a given execution stage. This pipeline will be called once for each stage, then execute all Workers in parallel. |
| Infant |The pipeline used to check when the Worker pipeline called by the Child completes and passes the resulting status back to the metadata database. |
| Recipient |A named person or generic account added with an email address to recieve alerts from the processing framework. |
| Alert Subscription |A metadata relationship between Worker pipelines and recipients to support email alerting. |

 
## Resources and Content

| ![alt text](https://mrpaulandrew.files.wordpress.com/2020/03/azure-square-logo.png?w=75 "Blog Icon") | Blogs |[mrpaulandrew.com/ADF.procfwk](https://mrpaulandrew.com/category/azure/data-factory/adf-procfwk/)|
|:----:|:----:|:----:|
| ![alt text](https://mrpaulandrew.files.wordpress.com/2018/11/github-icon.png?w=75 "GitHub Icon") | **GitHub** |**[github.com/mrpaulandrew/ADF.procfwk](https://github.com/mrpaulandrew/ADF.procfwk)**  |
| ![alt text](https://mrpaulandrew.files.wordpress.com/2020/03/twitterlogo.png?w=75 "Twitter Icon") | **Twitter** |**[#ADFprocfwk](https://twitter.com/search?q=%23ADFprocfwk&amp;src=hashtag_click)** |