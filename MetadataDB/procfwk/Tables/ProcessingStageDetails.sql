CREATE TABLE [procfwk].[ProcessingStageDetails] (
    [StageId]          INT            IDENTITY (1, 1) NOT NULL,
    [StageName]        VARCHAR (225)  NOT NULL,
    [StageDescription] VARCHAR (4000) NULL,
    [Enabled]          BIT            CONSTRAINT [DF_ProcessStageDetails_Enabled] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_ProcessStageDetails] PRIMARY KEY CLUSTERED ([StageId] ASC)
);

