CREATE TABLE [procfwk].[PipelineProcesses] (
    [PipelineId]   INT            IDENTITY (1, 1) NOT NULL,
    [DataFactoryId] INT NOT NULL,
    [StageId]      INT            NOT NULL,
    [PipelineName] NVARCHAR (200) NOT NULL,
    [Enabled]      BIT            CONSTRAINT [DF_PipelineProcesses_Enabled] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_PipelineProcesses] PRIMARY KEY CLUSTERED ([PipelineId] ASC),
    CONSTRAINT [FK_PipelineProcesses_ProcessingStageDetails] FOREIGN KEY ([StageId]) REFERENCES [procfwk].[ProcessingStageDetails] ([StageId]),
    CONSTRAINT [FK_PipelineProcesses_DataFactoryDetails] FOREIGN KEY([DataFactoryId]) REFERENCES [procfwk].[DataFactoryDetails] ([DataFactoryId])
);

