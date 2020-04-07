CREATE TABLE [procfwk].[Stages] (
    [StageId]          INT            IDENTITY (1, 1) NOT NULL,
    [StageName]        VARCHAR (225)  NOT NULL,
    [StageDescription] VARCHAR (4000) NULL,
    [Enabled]          BIT            CONSTRAINT [DF_Stages_Enabled] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Stages] PRIMARY KEY CLUSTERED ([StageId] ASC)
);

