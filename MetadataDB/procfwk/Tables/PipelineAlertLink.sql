CREATE TABLE [procfwk].[PipelineAlertLink]
	(
	[AlertId] INT IDENTITY(1,1) NOT NULL,
	[PipelineId] INT NOT NULL,
	[RecipientId] INT NOT NULL,
	[OutcomesBitValue] INT NOT NULL,
	[Enabled] BIT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_PipelineAlertLink] PRIMARY KEY CLUSTERED ([AlertId] ASC),
	CONSTRAINT [FK_PipelineAlertLink_Pipelines] FOREIGN KEY([PipelineId]) REFERENCES [procfwk].[Pipelines] ([PipelineId]),
	CONSTRAINT [FK_PipelineAlertLink_Recipients] FOREIGN KEY([RecipientId]) REFERENCES [procfwk].[Recipients] ([RecipientId])
	);