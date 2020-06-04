CREATE TABLE [procfwk].[Recipients]
	(
	[RecipientId] INT IDENTITY(1,1) NOT NULL,
	[Name] VARCHAR(255) NULL,
	[EmailAddress] NVARCHAR(500) NOT NULL,
	[MessagePreference] CHAR(3) NOT NULL DEFAULT ('TO'),
	CONSTRAINT [MessagePreferenceValue] CHECK ([MessagePreference] IN ('TO','CC','BCC')),
	[Enabled] BIT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_Recipients] PRIMARY KEY CLUSTERED ([RecipientId] ASC),
	CONSTRAINT [UK_EmailAddressMessagePreference] UNIQUE ([EmailAddress],[MessagePreference])
	);
