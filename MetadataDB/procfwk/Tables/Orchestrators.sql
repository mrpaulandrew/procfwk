CREATE TABLE [procfwk].[Orchestrators]
	(
	[OrchestratorId] [int] IDENTITY(1,1) NOT NULL,
	[OrchestratorName] NVARCHAR(200) NOT NULL,
	[OrchestratorType] CHAR(3) NOT NULL,
	[ResourceGroupName] NVARCHAR(200) NOT NULL, 
	[SubscriptionId] UNIQUEIDENTIFIER NOT NULL,
	[Description] NVARCHAR(MAX) NULL,
	CONSTRAINT [OrchestratorType] CHECK ([OrchestratorType] IN ('ADF','SYN')),
    CONSTRAINT [FK_Orchestrators_Subscriptions] FOREIGN KEY([SubscriptionId]) REFERENCES [procfwk].[Subscriptions] ([SubscriptionId]),
	CONSTRAINT [PK_Orchestrators] PRIMARY KEY CLUSTERED ([OrchestratorId] ASC)
	)