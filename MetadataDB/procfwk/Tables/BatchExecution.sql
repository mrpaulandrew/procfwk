CREATE TABLE [procfwk].[BatchExecution](
	[BatchId] [UNIQUEIDENTIFIER] NOT NULL,
	[ExecutionId] [UNIQUEIDENTIFIER] NOT NULL,
	[BatchName] VARCHAR(255) NOT NULL,
	[BatchStatus] [NVARCHAR](200) NOT NULL,
	[StartDateTime] [DATETIME] NOT NULL,
	[EndDateTime] [DATETIME] NULL,
	CONSTRAINT [PK_BatchExecution] PRIMARY KEY CLUSTERED 
	(
		[BatchId] ASC,
		[ExecutionId] ASC
	)
)


