# Stored Procedures

___
[<< Contents](/procfwk/contents) / [Database](/procfwk/database)

___
## CheckForBlockedPipelines

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@StageId|int

__Role:__ Used within parent [pipeline](/procfwk/pipelines) as part of the sequential foreach activity this procedure establishes if any worker pipelines in the next execution stage are blocked. Then depending on the configured [failure handing](/procfwk/failurehandling) updates the current execution [table](/procfwk/tables) before proceeding.

___

## CheckForEmailAlerts

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@PipelineId|int

__Role:__ Assuming [email alerting](/procfwk/eamilalerting) is enabled this procedure inspects the metadata [tables](/procfwk/tables) and returns a simple true or false (bit value) depending on what alerts are required for a given worker [pipeline](/procfwk/pipelines) Id. This checks is used within the infant pipeline before any effort is spent constructing email content to be sent.

___

## CheckMetadataIntegrity

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@DebugMode|bit

__Role:__ Called early on in the parent [pipeline](/procfwk/pipelines) this procedure serves two purposes. Firstly, to perform a series on basic checks against the database metadata ensuring key conditions are met before Data Factory starts a new execution. See [metadata integrity checks](/procfwk/metadataintegritychecks) for more details. 

Secondly, in the event of an external platform failure where the framework is left in an unexecpted state. This procedure queries the current execution [table](/procfwk/tables) and returns values to Data Factory so a [clean up](/procfwk/prevruncleanup) routine can take place as part of the parent [pipeline](/procfwk/pipelines) execution.

___

## CreateNewExecution

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@CallingDataFactoryName|nvarchar

__Role:__ Once the parent [pipeline](/procfwk/pipelines) has completed all pre-execution operations this procedure is used to set a new local execution Id (GUID) value and update the current execution table. For runtime perform an index re-build is also done by this procedure.

___

## ExecutePrecursorProcedure

__Schema:__ procfwk

__Role:__ See [Execution Precursor](/procfwk/executionprecursor) for details.

___

## ExecutionWrapper

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@CallingDataFactory|nvarchar

__Role:__ This procedure establishs what the framework should do with the current execution table when the parent pipeline is triggered. Depending on the configured [properties](/procfwk/properties) this will then create a new execution run or restart the previous run if a failure has occured.

___

## GetEmailAlertParts

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@PipelineId|int

__Role:__ When an [email alert](/procfwk/emailalerting) is going to be sent by the framework this procedure gathers up all required metadata parts for the [send email](/procfwk/sendemail) function. This includes the recipient, subject and body. The returning select statement means exactly the format required by the function allowing the infant pipeline to pass through the content from the lookup activity unchanged.

___

## GetPipelineParameters

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@PipelineId|int

__Role:__ Within the child pipeline foreach activity this procedure queries the metadata database for any parameters required by the given worker pipeline Id. What's returned by the stored procedure is a JSON safe string that can be injected into the [execute pipeline](/procfwk/executepipeline) function along with the other worker [pipeline](/procfwk/pipelines) details.

___

## GetPipelinesInStage

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@StageId|int

__Role:__ Called from the child [pipeline](/procfwk/pipeline) this procedure returns a simple list of all worker pipelines to be executed within a given [execution stage](/procfwk/executionstage). Filtering ensures only worker pipelines that haven't already completed successfully or workers that aren't blocked are returned.

___

## GetPropertyValue

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@PropertyName|varchar

__Role:__ This procedure is used by [Data Factory](/procfwk/datafactory) through the framework [pipelines](/procfwk/pipelines) to return a [property](/procfwk/properties) value from a provided name. This is done so Data Factory can use the SELECT output value directly, rather than this being an actual OUTPUT of the procedure.

___

## GetServicePrincipal

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@DataFactory|nvarchar
|@PipelineName|nvarchar

__Role:__ Depending on the configured [properties](/procfwk/properties) this procedure queries the service principal table and returns credentials that [Data Factory](/procfwk/datafactory) can use when executing a worker pipeline. See [worker SPN storage](/procfwk/spnhandling) for more details.

___

## GetStages

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier

__Role:__ Does stuff.

___

## ResetExecution

__Schema:__ procfwk

__Role:__ Does stuff.

___

## SetErrorLogDetails

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@LocalExecutionId|uniqueidentifier
|@JsonErrorDetails|varchar

__Role:__ Does stuff.

___

## SetExecutionBlockDependants

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@PipelineId|int

__Role:__ Does stuff.

___

## SetLogActivityFailed

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int
|@CallingActivity|varchar

__Role:__ Does stuff.

___

## SetLogPipelineCancelled

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int

__Role:__ Does stuff.

___

## SetLogPipelineChecking

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int

__Role:__ Does stuff.

___

## SetLogPipelineFailed

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int
|@RunId|uniqueidentifier

__Role:__ Does stuff.

___

## SetLogPipelineLastStatusCheck

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int

__Role:__ Does stuff.

___

## SetLogPipelineRunId

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int
|@RunId|uniqueidentifier

__Role:__ Does stuff.

___

## SetLogPipelineRunning

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int

__Role:__ Does stuff.

___

## SetLogPipelineSuccess

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int

__Role:__ Does stuff.

___

## SetLogPipelineUnknown

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int
|@PipelineId|int

__Role:__ Does stuff.

___

## SetLogStagePreparing

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@ExecutionId|uniqueidentifier
|@StageId|int

__Role:__ Does stuff.

___

## UpdateExecutionLog

__Schema:__ procfwk

|Parameter Name|Data Type|
|---|:---:|
|@PerformErrorCheck|bit

__Role:__ Does stuff.

___

## AddPipelineDependant

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@PipelineName|nvarchar
|@DependantPipelineName|nvarchar

__Role:__ Does stuff.

___

## AddPipelineViaPowerShell

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@ResourceGroup|nvarchar
|@DataFactoryName|nvarchar
|@PipelineName|nvarchar

__Role:__ Does stuff.

___

## AddProperty

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@PropertyName|varchar
|@PropertyValue|nvarchar
|@Description|nvarchar

__Role:__ Does stuff.

___

## AddRecipientPipelineAlerts

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@RecipientName|varchar
|@PipelineName|nvarchar
|@AlertForStatus|nvarchar

__Role:__ Does stuff.

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

__Role:__ Does stuff.

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

__Role:__ Does stuff.

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

__Role:__ Does stuff.

___

## CheckStageAndPiplineIntegrity

__Schema:__ procfwkHelpers

__Role:__ Does stuff.

___

## DeleteMetadataWithIntegrity

__Schema:__ procfwkHelpers

__Role:__ Does stuff.

___

## DeleteMetadataWithoutIntegrity

__Schema:__ procfwkHelpers

__Role:__ Does stuff.

___

## DeleteRecipientAlerts

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@EmailAddress|nvarchar
|@SoftDeleteOnly|bit

__Role:__ Does stuff.

___

## DeleteServicePrincipal

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@DataFactory|nvarchar
|@PrincipalIdValue|nvarchar
|@SpecificPipelineName|nvarchar

__Role:__ Does stuff.

___

## GetExecutionDetails

__Schema:__ procfwkHelpers

|Parameter Name|Data Type|
|---|:---:|
|@LocalExecutionId|uniqueidentifier

__Role:__ Does stuff.

___

## SetDefaultAlertOutcomes

__Schema:__ procfwkHelpers

__Role:__ Does stuff.

___

## SetDefaultDataFactorys

__Schema:__ procfwkHelpers

__Role:__ Does stuff.

___

## SetDefaultPipelineDependant

__Schema:__ procfwkHelpers

__Role:__ Does stuff.

___

## SetDefaultPipelineDependants

__Schema:__ procfwkHelpers

__Role:__ Does stuff.

___

## SetDefaultPipelineParameters

__Schema:__ procfwkHelpers

__Role:__ Does stuff.

___

## SetDefaultPipelines

__Schema:__ procfwkHelpers

__Role:__ Does stuff.

___

## SetDefaultProperties

__Schema:__ procfwkHelpers

__Role:__ Does stuff.

___

## SetDefaultRecipientPipelineAlerts

__Schema:__ procfwkHelpers

__Role:__ Does stuff.

___

## SetDefaultRecipients

__Schema:__ procfwkHelpers

__Role:__ Does stuff.

___

## SetDefaultStages

__Schema:__ procfwkHelpers

__Role:__ Does stuff.

___

## Add300WorkerPipelines

__Schema:__ procfwkTesting

__Role:__ Does stuff.

___

## CleanUpMetadata

__Schema:__ procfwkTesting

__Role:__ Does stuff.

___

## GetRunIdWhenAvailable

__Schema:__ procfwkTesting

|Parameter Name|Data Type|
|---|:---:|
|@PipelineName|nvarchar

__Role:__ Does stuff.

___

## ResetMetadata

__Schema:__ procfwkTesting

__Role:__ Does stuff.

___
