# Glossary

___
[<< Contents](/procfwk/contents) 

___

Depending on your experience with Azure some of the below might be obvious. However, as a baseline this glossary has been created to provide definitions in the specfic context of the processing framework solution.

| Term | Explanation and Context |
|:----:|--------------|
| PaaS |Platform as a Service |
| Framework |A collection of resources that operate as a single structure to support a system. |
| Metadata |Data the represents other processes and information about how a solution is going to be controlled by the framework. |
| Orchestrator |A generalisation of resources that are interchangeable within the processing framework when delivering pipelines of all forms from a common code base. |
| Orchestrator Type |Identifies from the generalisation of orchestrators the specific type of resource to be used. Either ADF = Azure Data Factory or SYN = Azure Synapse Analytics. |
| Azure Data Factory |The Microsoft PaaS offering used for solution orchestration and one of the resources that can be used to deliver the metadata driven processing framework pipelines. |
| Azure Synapse Analytics |The Microsoft PaaS offering used for solution orchestration and one of the resources that can be used to deliver the metadata driven processing framework pipelines. |
| Azure SQLDB |The Microsoft PaaS relational database offering used to house the framework metadata. |
| Azure Function |The serverless executable code used by the framework to perform discrete and repeatable processes using simple HTTP requests. |
| Azure Function App |The Microsoft Paas offering the represents the application used to house Azure Functions. |
| ADF |An acronym for Azure Data Factory.  |
| SYN |An abreviation for Azure Synase Analytics.  |
| procfwk |An acronym to represent the Processing Framework solution delivered by the code project. |
| Linked Service |A component of orchestrator used as an endpoint connection allowing the orchestrator to authenticate with other services. |
| Dataset |A component of the orchestrator used to define the input, output or means in which another service should be used. A Dataset requires a Linked Service to authenticate. |
| Activity |A component of the orchestrator tailored to the requirements of a given operation or task. An Activity may use Datasets and Linked Service as part of its definition. |
| Pipeline |A component of the orchestrator used as a logic housing for groups of Activities needed to perform an operation. |
| Trigger |A component of the orchestrator used to perform execution of Pipelines at defined points or schedules. |
| ForEach |A concept used to represent an iterative process but also a named Activity within the orchestrator with special features that mean all iteration instants can be called either in parallel or sequentially. |
| Until |A concept used to represent an iterative process that will continue until a logical condition is met. Until is also a named Activity within the orchestrator delivering the same capability as its intended concept. |
| Batch |A complete set of data processing operations to be completed end to end. For example; hourly, daily, weekly. Batches can be executed concurrently by the processing framework.  |
| Stage |A set of or just one process that needs to be executed by the metadata driven framework. When multiple stages are defined, they will be executed sequentially and it is expected that stages will form a chain of upstream and downstream dependencies.  |
| Worker |A pipeline created in ADF to house custom code and activities doing whatever you require for your solution. The Worker pipeline is then registered in the metadata for a processing stage that tells the Child pipeline what it needs to go and call. |
| Grandparent |The pipeline used within the orchestrator to optionally bootstrap any wider processes before calling the main processing framework pipeline. |
| Parent |The pipeline used to bootstrap the orchestration framework in perform the first level ForEach calls in sequence for the metadata stages. |
| Child |The pipeline used to execute Worker pipelines within a given execution stage. This pipeline will be called once for each stage, then execute all Workers in parallel. |
| Infant |The pipeline used to check when the Worker pipeline called by the Child completes and passes the resulting status back to the metadata database. |
| Recipient |A named person or generic account added with an email address to recieve alerts from the processing framework. |
| Alert Subscription |A metadata relationship between Worker pipelines and recipients to support email alerting. |