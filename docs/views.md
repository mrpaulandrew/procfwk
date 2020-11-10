# Views

___
[<< Contents](/procfwk/contents) / [Database](/procfwk/database)

___

As a general rule within the processing framework database views are used for convenience, aggregation and to return de-normalised results from the core metadata [tables](/procfwk/tables).

## CurrentProperties
__Schema:__ procfwk

__Role:__ Applies filtering to the underlying properties [table](/procfwk/tables) returning only property values currently in use. Eg. Without an end date value.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|PropertyName|varchar|128|No
|2|PropertyValue|nvarchar|max|No


## PipelineParameterDataSizes
__Schema:__ procfwk

__Role:__ Used in conjunction with the [procfwk].[[CheckMetadataIntegrity](/procfwk/metadataintegritychecks)] [stored procedure](/procfwk/storedprocedures) this view aggregates all existing pipeline parameters return a memory size value. This is wrapped up and later used to ensure request body created for the [execute pipeline](/procfwk/executepipeline) function is within service limitations.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|PipelineId|int|4|No
|2|Size|decimal|17|Yes


## PipelineDependencyChains
__Schema:__ procfwkHelpers

__Role:__ Joins pipelines within dependant pipelines to return a convenient list of stage and pipeline name values based on the [worker pipeline dependency chain](/procfwk/dependencychains).

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|PredecessorStage|varchar|225|No
|2|PredecessorPipeline|nvarchar|400|No
|3|DependantStage|varchar|225|No
|4|DependantPipeline|nvarchar|400|No


## AverageStageDuration
__Schema:__ procfwkReporting

__Role:__ Used to aggregate [execution stage](/procfwk/executionstages) which is used as part of the Power BI framework [reporting](/procfwk/reporting) model.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|StageId|int|4|No
|2|StageName|varchar|225|No
|3|StageDescription|varchar|4000|Yes
|4|AvgStageRunDurationMinutes|int|4|Yes


## CompleteExecutionErrorLog
__Schema:__ procfwkReporting

__Role:__ De-normalizes several execution tables into a convenient list of values for a given set of failed Worker [pipelines](/procfwk/[pipelines).

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|ExecutionLogId|int|4|No
|2|ErrorLogId|int|4|No
|3|LocalExecutionId|uniqueidentifier|16|No
|4|ProcessingDateTime|datetime|8|Yes
|5|CallingDataFactoryName|nvarchar|400|No
|6|WorkerDataFactory|nvarchar|400|No
|7|WorkerPipelineName|nvarchar|400|No
|8|PipelineStatus|nvarchar|400|Yes
|9|ActivityRunId|uniqueidentifier|16|No
|10|ActivityName|varchar|100|No
|11|ActivityType|varchar|100|No
|12|ErrorCode|varchar|100|No
|13|ErrorType|varchar|100|No
|14|ErrorMessage|nvarchar|max|Yes


## CompleteExecutionLog
__Schema:__ procfwkReporting

__Role:__ De-normalizes and aggregates several execution tables into a convenient list of values for all Worker [pipelines](/procfwk/[pipelines) executions records.

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
|12|RunDurationMinutes|int|4|Yes


## CurrentExecutionSummary
__Schema:__ procfwkReporting

__Role:__ Provides a simple count of worker pipelines by their pipeline status to view a summary of the current framework run.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|PipelineStatus|nvarchar|400|No
|2|RecordCount|int|4|Yes


## LastExecution
__Schema:__ procfwkReporting

__Role:__ Provides a convenient  filter using the max log ID value to return only the last complete set of framework execution information.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|LogId|int|4|No
|2|StageId|int|4|No
|3|PipelineId|int|4|No
|4|PipelineName|nvarchar|400|No
|5|StartDateTime|datetime|8|Yes
|6|PipelineStatus|nvarchar|400|Yes
|7|EndDateTime|datetime|8|Yes
|8|RunDurationMinutes|int|4|Yes


## LastExecutionSummary
__Schema:__ procfwkReporting

__Role:__ Provides a convenient  filter using the max log ID value to return an aggregation for run duration for only the last complete set of framework execution information.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|LocalExecutionId|uniqueidentifier|16|No
|2|RunDurationMinutes|int|4|Yes


## WorkerParallelismOverTime
__Schema:__ procfwkReporting

__Role:__ Using time values per minute offers a view of execution stage [worker pipeline parallelism](/procfwk/scaleoutprocessing) at each point in time throughout the duration of a complete execution run.

|Id|Attribute|Data Type|Length|Nullable
|:---:|---|---|:---:|:---:|
|1|WallclockDate|date|3|Yes
|2|WallclockTime|time|5|Yes
|3|LocalExecutionId|uniqueidentifier|16|No
|4|StageName|varchar|225|No
|5|PipelineName|nvarchar|8000|Yes
|6|WorkerCount|int|4|Yes

