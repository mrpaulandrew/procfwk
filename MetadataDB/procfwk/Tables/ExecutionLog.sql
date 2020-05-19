CREATE TABLE [procfwk].[ExecutionLog] (
    [LogId]            INT              IDENTITY (1, 1) NOT NULL,
    [LocalExecutionId] UNIQUEIDENTIFIER NOT NULL,
    [StageId]          INT              NOT NULL,
    [PipelineId]       INT              NOT NULL,
    [CallingDataFactoryName] NVARCHAR(200) NOT NULL DEFAULT ('Unknown'),
    [ResourceGroupName] NVARCHAR(200) NOT NULL DEFAULT ('Unknown'),
	[DataFactoryName] NVARCHAR(200) NOT NULL DEFAULT ('Unknown'),
    [PipelineName]     NVARCHAR (200)   NOT NULL,
    [StartDateTime]    DATETIME         NULL,
    [PipelineStatus]   NVARCHAR (200)   NULL,
    [EndDateTime]      DATETIME         NULL,
    [AdfPipelineRunId] UNIQUEIDENTIFIER NULL,
    [PipelineParamsUsed] NVARCHAR(MAX) NULL DEFAULT ('None'), 
    CONSTRAINT [PK_ExecutionLog] PRIMARY KEY CLUSTERED ([LogId] ASC)
);

