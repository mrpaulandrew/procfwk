# Tables

___
[<< Contents](/ADF.procfwk/contents) / [Database](/ADF.procfwk/database)

___

## AlertOutcomes
__Schema:__ procfwk

__Definition:__ Used to provide a static list of available pipeline status outcomes that can be compared to email recipient requirements for event alerts at runtime. These status values are used in the context of a bitmask potition when the framework performs any [email alerting](/ADF.procfwk/emailalerting).

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|OutcomeBitPosition|int|4|No
|2|PipelineOutcomeStatus|nvarchar|400|No
|3|BitValue|int|4|Yes

___

## CurrentExecution
__Schema:__ procfwk

__Definition:__ For a given execution run this table will be used to handle all metadata exchanges between

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

__Definition:__ Stores things.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|DataFactoryId|int|4|No
|2|DataFactoryName|nvarchar|400|No
|3|ResourceGroupName|nvarchar|400|No
|4|Description|nvarchar|max|Yes


## ErrorLog
__Schema:__ procfwk

__Definition:__ Stores things.

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

__Definition:__ Stores things.

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

__Definition:__ Stores things.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|AlertId|int|4|No
|2|PipelineId|int|4|No
|3|RecipientId|int|4|No
|4|OutcomesBitValue|int|4|No
|5|Enabled|bit|1|No


## PipelineAuthLink
__Schema:__ procfwk

__Definition:__ Stores things.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|AuthId|int|4|No
|2|PipelineId|int|4|No
|3|DataFactoryId|int|4|No
|4|CredentialId|int|4|No


## PipelineDependencies
__Schema:__ procfwk

__Definition:__ Stores things.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|DependencyId|int|4|No
|2|PipelineId|int|4|No
|3|DependantPipelineId|int|4|No


## PipelineParameters
__Schema:__ procfwk

__Definition:__ Stores things.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|ParameterId|int|4|No
|2|PipelineId|int|4|No
|3|ParameterName|varchar|128|No
|4|ParameterValue|nvarchar|max|Yes


## Pipelines
__Schema:__ procfwk

__Definition:__ Stores things.

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

__Definition:__ Stores things.

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

__Definition:__ Stores things.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|RecipientId|int|4|No
|2|Name|varchar|255|Yes
|3|EmailAddress|nvarchar|1000|No
|4|MessagePreference|char|3|No
|5|Enabled|bit|1|No


## ServicePrincipals
__Schema:__ dbo

__Definition:__ Stores things.

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

__Definition:__ Stores things.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|StageId|int|4|No
|2|StageName|varchar|225|No
|3|StageDescription|varchar|4000|Yes
|4|Enabled|bit|1|No

