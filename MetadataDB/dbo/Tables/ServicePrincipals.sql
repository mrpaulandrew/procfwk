CREATE TABLE [dbo].[ServicePrincipals](
	[CredentialId] [int] IDENTITY(1,1) NOT NULL,
	[PrincipalName] [nvarchar](256) NULL,
	[PrincipalId] [uniqueidentifier] NOT NULL,
	[PrincipalSecret] [varbinary](256) NOT NULL,
	CONSTRAINT [PK_ServicePrincipals] PRIMARY KEY CLUSTERED ([CredentialId] ASC)
	)
GO
