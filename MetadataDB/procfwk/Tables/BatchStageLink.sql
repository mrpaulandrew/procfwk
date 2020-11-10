CREATE TABLE [procfwk].[BatchStageLink]
	(
	[BatchId] [UNIQUEIDENTIFIER] NOT NULL,
	[StageId] [INT] NOT NULL,
	 CONSTRAINT [PK_BatchStageLink] PRIMARY KEY CLUSTERED 
	(
		[BatchId] ASC,
		[StageId] ASC
	)
)
