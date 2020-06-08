CREATE TABLE [procfwk].[CurrentExecution] (
    [LocalExecutionId] UNIQUEIDENTIFIER NOT NULL,
    [StageId]          INT              NOT NULL,
    [PipelineId]       INT              NOT NULL,
    [CallingDataFactoryName] NVARCHAR(200) NOT NULL,
    [ResourceGroupName]NVARCHAR (200)   NOT NULL,
    [DataFactoryName]  NVARCHAR (200)   NOT NULL,
    [PipelineName]     NVARCHAR (200)   NOT NULL,
    [StartDateTime]    DATETIME         NULL,
    [PipelineStatus]   NVARCHAR (200)   NULL,
    [LastStatusCheckDateTime] DATETIME  NULL,
    [EndDateTime]      DATETIME         NULL,
    [IsBlocked] BIT NOT NULL DEFAULT 0,
    [AdfPipelineRunId] UNIQUEIDENTIFIER NULL,
    [PipelineParamsUsed] NVARCHAR(MAX) NULL, 
    CONSTRAINT [PK_CurrentExecution] PRIMARY KEY CLUSTERED ([LocalExecutionId] ASC, [StageId] ASC, [PipelineId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IDX_GetPipelinesInStage] ON [procfwk].[CurrentExecution]
    (
    [StageId],
    [PipelineStatus]
    )
INCLUDE
    (
    [PipelineId],
    [PipelineName],
    [DataFactoryName],
    [ResourceGroupName]
    )
GO
