CREATE TABLE [procfwk].[Subscriptions]
	(
	[SubscriptionId] UNIQUEIDENTIFIER NOT NULL,
	[Name] NVARCHAR(200) NOT NULL,
	[Description] NVARCHAR(MAX) NULL,
	[TenantId] UNIQUEIDENTIFIER NOT NULL,
	CONSTRAINT [PK_Subscriptions] PRIMARY KEY CLUSTERED ([SubscriptionId] ASC),
	CONSTRAINT [FK_Subscriptions_Tenants] FOREIGN KEY([TenantId]) REFERENCES [procfwk].[Tenants] ([TenantId])
	)