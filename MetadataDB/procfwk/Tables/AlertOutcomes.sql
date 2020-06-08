CREATE TABLE [procfwk].[AlertOutcomes]
	(
	[OutcomeBitPosition] INT IDENTITY(0,1) NOT NULL,
	[PipelineOutcomeStatus] NVARCHAR(200) NOT NULL,
	[BitValue]  AS (POWER((2),[OutcomeBitPosition])),
	CONSTRAINT [PK_AlertOutcomes] PRIMARY KEY CLUSTERED ([OutcomeBitPosition] ASC),
	CONSTRAINT [UK_PipelineOutcomeStatus] UNIQUE ([PipelineOutcomeStatus])
	)