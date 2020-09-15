CREATE TABLE [procfwk].[DataFactorys]
	(
	[DataFactoryId] [int] IDENTITY(1,1) NOT NULL,
	[DataFactoryName] NVARCHAR(200) NOT NULL,
	[ResourceGroupName] NVARCHAR(200) NOT NULL, 
	[SubscriptionId] UNIQUEIDENTIFIER NOT NULL,
	[Description] NVARCHAR(MAX) NULL,	
    CONSTRAINT [FK_DataFactorys_Subscriptions] FOREIGN KEY([SubscriptionId]) REFERENCES [procfwk].[Subscriptions] ([SubscriptionId]),
	CONSTRAINT [PK_DataFactorys] PRIMARY KEY CLUSTERED ([DataFactoryId] ASC)
	)