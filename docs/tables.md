# Tables

___
[<< Contents](/procfwk/contents) / [Database](/procfwk/database)

___

## AlertOutcomes
__Schema:__ procfwk

__Definition:__ Used to provide a static list of available pipeline status outcomes that can be compared to email recipient requirements for event alerts at runtime. These status values are used in the context of a bitmask position when the framework performs any [email alerting](/procfwk/emailalerting). The position means an email recipient can subscribe to any combination of pipeline outcomes.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|OutcomeBitPosition|int|4|No
|2|PipelineOutcomeStatus|nvarchar|400|No
|3|BitValue|int|4|Yes


## CurrentExecution
__Schema:__ procfwk

__Definition:__ For a given execution run this table will be used to handle all metadata exchanges between Data Factory and the database. After a successful run the table is truncated. Indexing is used here to ensure the current execution run has access to the requested metadata given common where clause requirements.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|LocalExecutionId|uniqueidentifier|16|No
|2|StageId|int|4|No
|3|PipelineId|int|4|No
|4|CallingDataFactoryName|nvarchar|400|No
|5|ResourceGroupName|nvarchar|400|No
|6|DataFactoryName|nvarchar|400|No
|7|PipelineName|nvarchar|400|No
|8|StartDateTime|datetime|8|Yes
|9|PipelineStatus|nvarchar|400|Yes
|10|LastStatusCheckDateTime|datetime|8|Yes
|11|EndDateTime|datetime|8|Yes
|12|IsBlocked|bit|1|No
|13|AdfPipelineRunId|uniqueidentifier|16|Yes
|14|PipelineParamsUsed|nvarchar|max|Yes


## DataFactorys
__Schema:__ procfwk

__Definition:__ To support the [decoupling](/procfwk/workerdecoupling) of worker [pipelines](/procfwk/pipelines) from the orchestration [pipelines](/procfwk/pipelines) this table houses information about the Data Factory resources used by the framework when executing workers. It does not need to contain data about the Data Factory where the orchestration [pipelines](/procfwk/pipelines) are running from.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|DataFactoryId|int|4|No
|2|DataFactoryName|nvarchar|400|No
|3|ResourceGroupName|nvarchar|400|No
|4|SubscriptionId|uniqueidentifier|16|No
|5|Description|nvarchar|max|Yes


## ErrorLog
__Schema:__ procfwk

__Definition:__ In the event of a worker pipeline failure, activity level error message details will be captured and inserted into this table.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|LogId|int|4|No
|2|LocalExecutionId|uniqueidentifier|16|No
|3|AdfPipelineRunId|uniqueidentifier|16|No
|4|ActivityRunId|uniqueidentifier|16|No
|5|ActivityName|varchar|100|No
|6|ActivityType|varchar|100|No
|7|ErrorCode|varchar|100|No
|8|ErrorType|varchar|100|No
|9|ErrorMessage|nvarchar|max|Yes


## ExecutionLog
__Schema:__ procfwk

__Definition:__ This table is used as a long term store from the current execution table. When the current execution table is cleared now records will be moved here.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|LogId|int|4|No
|2|LocalExecutionId|uniqueidentifier|16|No
|3|StageId|int|4|No
|4|PipelineId|int|4|No
|5|CallingDataFactoryName|nvarchar|400|No
|6|ResourceGroupName|nvarchar|400|No
|7|DataFactoryName|nvarchar|400|No
|8|PipelineName|nvarchar|400|No
|9|StartDateTime|datetime|8|Yes
|10|PipelineStatus|nvarchar|400|Yes
|11|EndDateTime|datetime|8|Yes
|12|AdfPipelineRunId|uniqueidentifier|16|Yes
|13|PipelineParamsUsed|nvarchar|max|Yes


## PipelineAlertLink
__Schema:__ procfwk

__Definition:__ This table provides a many to many connection between the email recipients and the [pipelines](/procfwk/pipelines) they wish to subscribe to for email alerts.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|AlertId|int|4|No
|2|PipelineId|int|4|No
|3|RecipientId|int|4|No
|4|OutcomesBitValue|int|4|No
|5|Enabled|bit|1|No


## PipelineAuthLink
__Schema:__ procfwk

__Definition:__ For the purposes of granular sercurity when providing service principal details that can be used to execute worker [pipelines](/procfwk/pipelines) this table provides that many to many link and has further referential integrity checks against the Data Factory as well.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|AuthId|int|4|No
|2|PipelineId|int|4|No
|3|DataFactoryId|int|4|No
|4|CredentialId|int|4|No


## PipelineDependencies
__Schema:__ procfwk

__Definition:__ When using the failure handling [property](/procfwk/properties) this table is used to establish the links for worker [pipelines](/procfwk/pipelines) across the [execution stages](/procfwk/executionstages).

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|DependencyId|int|4|No
|2|PipelineId|int|4|No
|3|DependantPipelineId|int|4|No


## PipelineParameters
__Schema:__ procfwk

__Definition:__ Worker pipeline parameters are sorted in this table as metadata and provided to the worker at runtime by the framework. A given worker can have none or many parameters limited only by the underlying resources in terms of amount and size.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|ParameterId|int|4|No
|2|PipelineId|int|4|No
|3|ParameterName|varchar|128|No
|4|ParameterValue|nvarchar|max|Yes


## Pipelines
__Schema:__ procfwk

__Definition:__ This core table in the framework houses all worker [pipelines](/procfwk/pipelines) that the framework is expected to call per [execution stage](/procfwk/executionstage) and for a given worker Data Factory.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|PipelineId|int|4|No
|2|DataFactoryId|int|4|No
|3|StageId|int|4|No
|4|PipelineName|nvarchar|400|No
|5|LogicalPredecessorId|int|4|Yes
|6|Enabled|bit|1|No


## Properties
__Schema:__ procfwk

__Definition:__ [Properties](/procfwk/properties) and values housed in this table provide runtime configuration information for the framework to influence behaviour and setup.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|PropertyId|int|4|No
|2|PropertyName|varchar|128|No
|3|PropertyValue|nvarchar|max|No
|4|Description|nvarchar|max|Yes
|5|ValidFrom|datetime|8|No
|6|ValidTo|datetime|8|Yes



## Recipients
__Schema:__ procfwk

__Definition:__ Named people and email addresses are stored in this table for the purposes of providing [email alerting](/procfwk/emailalerting) when worker [pipelines](/procfwk/pipelines) are executed by the framework.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|RecipientId|int|4|No
|2|Name|varchar|255|Yes
|3|EmailAddress|nvarchar|1000|No
|4|MessagePreference|char|3|No
|5|Enabled|bit|1|No


## ServicePrincipals
__Schema:__ dbo

__Definition:__ At runtime a worker [pipeline](/procfwk/pipelines) will be executed by the framework [functions](/procfwk/functions). The function will authenticate against the target worker data factory using SPN details sorted in this table directly, or referenced by this tableto Azure Key Vault.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|CredentialId|int|4|No
|2|PrincipalName|nvarchar|512|Yes
|3|PrincipalId|uniqueidentifier|16|Yes
|4|PrincipalSecret|varbinary|256|Yes
|5|PrincipalIdUrl|nvarchar|max|Yes
|6|PrincipalSecretUrl|nvarchar|max|Yes


## Stages
__Schema:__ procfwk

__Definition:__ This core table in the framework houses details of all the sequential [execution stages](/procfwk/executionstages) that need to process by the framework in order based on the stage Id.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|StageId|int|4|No
|2|StageName|varchar|225|No
|3|StageDescription|varchar|4000|Yes
|4|Enabled|bit|1|No

## Subscriptions
__Schema:__ procfwk

__Definition:__ To support the [decoupling](/procfwk/workerdecoupling) of pipelines and [Data Factory's](/procfwk/datafactory) this table houses details of Azure Subscriptions that are connected with 1 or many worker Data Factory instances.

At least 1 subscription must exist within the metadata.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|SubscriptionId|uniqueidentifier|16|No
|2|Name|nvarchar|400|No
|3|Description|nvarchar|max|Yes
|4|TenantId|uniqueidentifier|16|No


## Tenants
__Schema:__ procfwk

__Definition:__ To support the [decoupling](/procfwk/workerdecoupling) of pipelines within [Data Factory's](/procfwk/datafactory) at this final level tenant details are sorted within this table and connected to 1 or many Azure Subscriptions.

At least 1 tenant must exist within the metadata.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|TenantId|uniqueidentifier|16|No
|2|Name|nvarchar|400|No
|3|Description|nvarchar|max|Yes