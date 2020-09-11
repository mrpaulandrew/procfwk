# Stored Procedures

___
[<< Contents](/ADF.procfwk/contents) / [Database](/ADF.procfwk/database)

___
## CheckForBlockedPipelines

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@StageId|int

__Definition:__ Does stuff.

___

## CheckForEmailAlerts

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@PipelineId|int

__Definition:__ Does stuff.

___

## CheckMetadataIntegrity

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@DebugMode|bit

__Definition:__ Does stuff.

___

## CreateNewExecution

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@CallingDataFactoryName|nvarchar

__Definition:__ Does stuff.

___

## ExecutePrecursorProcedure

__Schema:__ procfwk

__Definition:__ Does stuff.

___

## ExecutionWrapper

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@CallingDataFactory|nvarchar

__Definition:__ Does stuff.

___

## GetEmailAlertParts

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@PipelineId|int

__Definition:__ Does stuff.

___

## GetPipelineParameters

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@PipelineId|int

__Definition:__ Does stuff.

___

## GetPipelinesInStage

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@StageId|int

__Definition:__ Does stuff.

___

## GetPropertyValue

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@PropertyName|varchar

__Definition:__ Does stuff.

___

## GetServicePrincipal

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@DataFactory|nvarchar
|@PipelineName|nvarchar

__Definition:__ Does stuff.

___

## GetStages

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier

__Definition:__ Does stuff.

___

## ResetExecution

__Schema:__ procfwk

__Definition:__ Does stuff.

___

## SetErrorLogDetails

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@LocalExecutionId|uniqueidentifier
|@JsonErrorDetails|varchar

__Definition:__ Does stuff.

___

## SetExecutionBlockDependants

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@PipelineId|int

__Definition:__ Does stuff.

___

## SetLogActivityFailed

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int
|@CallingActivity|varchar

__Definition:__ Does stuff.

___

## SetLogPipelineCancelled

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int

__Definition:__ Does stuff.

___

## SetLogPipelineChecking

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int

__Definition:__ Does stuff.

___

## SetLogPipelineFailed

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int
|@RunId|uniqueidentifier

__Definition:__ Does stuff.

___

## SetLogPipelineLastStatusCheck

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int

__Definition:__ Does stuff.

___

## SetLogPipelineRunId

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int
|@RunId|uniqueidentifier

__Definition:__ Does stuff.

___

## SetLogPipelineRunning

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int

__Definition:__ Does stuff.

___

## SetLogPipelineSuccess

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int

__Definition:__ Does stuff.

___

## SetLogPipelineUnknown

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int

__Definition:__ Does stuff.

___

## SetLogStagePreparing

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int

__Definition:__ Does stuff.

___

## UpdateExecutionLog

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@PerformErrorCheck|bit

__Definition:__ Does stuff.

___

## AddPipelineDependant

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@PipelineName|nvarchar
|@DependantPipelineName|nvarchar

__Definition:__ Does stuff.

___

## AddPipelineViaPowerShell

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@ResourceGroup|nvarchar
|@DataFactoryName|nvarchar
|@PipelineName|nvarchar

__Definition:__ Does stuff.

___

## AddProperty

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@PropertyName|varchar
|@PropertyValue|nvarchar
|@Description|nvarchar

__Definition:__ Does stuff.

___

## AddRecipientPipelineAlerts

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@RecipientName|varchar
|@PipelineName|nvarchar
|@AlertForStatus|nvarchar

__Definition:__ Does stuff.

___

## AddServicePrincipal

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@DataFactory|nvarchar
|@PrincipalId|nvarchar
|@PrincipalSecret|nvarchar
|@SpecificPipelineName|nvarchar
|@PrincipalName|nvarchar

__Definition:__ Does stuff.

___

## AddServicePrincipalUrls

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@DataFactory|nvarchar
|@PrincipalIdUrl|nvarchar
|@PrincipalSecretUrl|nvarchar
|@SpecificPipelineName|nvarchar
|@PrincipalName|nvarchar

__Definition:__ Does stuff.

___

## AddServicePrincipalWrapper

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@DataFactory|nvarchar
|@PrincipalIdValue|nvarchar
|@PrincipalSecretValue|nvarchar
|@SpecificPipelineName|nvarchar
|@PrincipalName|nvarchar

__Definition:__ Does stuff.

___

## CheckStageAndPiplineIntegrity

__Schema:__ procfwkHelpers

__Definition:__ Does stuff.

___

## DeleteMetadataWithIntegrity

__Schema:__ procfwkHelpers

__Definition:__ Does stuff.

___

## DeleteMetadataWithoutIntegrity

__Schema:__ procfwkHelpers

__Definition:__ Does stuff.

___

## DeleteRecipientAlerts

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@EmailAddress|nvarchar
|@SoftDeleteOnly|bit

__Definition:__ Does stuff.

___

## DeleteServicePrincipal

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@DataFactory|nvarchar
|@PrincipalIdValue|nvarchar
|@SpecificPipelineName|nvarchar

__Definition:__ Does stuff.

___

## GetExecutionDetails

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@LocalExecutionId|uniqueidentifier

__Definition:__ Does stuff.

___

## SetDefaultAlertOutcomes

__Schema:__ procfwkHelpers

__Definition:__ Does stuff.

___

## SetDefaultDataFactorys

__Schema:__ procfwkHelpers

__Definition:__ Does stuff.

___

## SetDefaultPipelineDependant

__Schema:__ procfwkHelpers

__Definition:__ Does stuff.

___

## SetDefaultPipelineDependants

__Schema:__ procfwkHelpers

__Definition:__ Does stuff.

___

## SetDefaultPipelineParameters

__Schema:__ procfwkHelpers

__Definition:__ Does stuff.

___

## SetDefaultPipelines

__Schema:__ procfwkHelpers

__Definition:__ Does stuff.

___

## SetDefaultProperties

__Schema:__ procfwkHelpers

__Definition:__ Does stuff.

___

## SetDefaultRecipientPipelineAlerts

__Schema:__ procfwkHelpers

__Definition:__ Does stuff.

___

## SetDefaultRecipients

__Schema:__ procfwkHelpers

__Definition:__ Does stuff.

___

## SetDefaultStages

__Schema:__ procfwkHelpers

__Definition:__ Does stuff.

___

## Add300WorkerPipelines

__Schema:__ procfwkTesting

__Definition:__ Does stuff.

___

## CleanUpMetadata

__Schema:__ procfwkTesting

__Definition:__ Does stuff.

___

## GetRunIdWhenAvailable

__Schema:__ procfwkTesting

|Parameter Name|Data Type|
|---|:---:|
|@PipelineName|nvarchar

__Definition:__ Does stuff.

___

## ResetMetadata

__Schema:__ procfwkTesting

__Definition:__ Does stuff.

___
