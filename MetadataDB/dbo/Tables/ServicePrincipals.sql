CREATE TABLE [dbo].[ServicePrincipals](
	[CredentialId] INT IDENTITY(1,1) NOT NULL,
	[PrincipalName] NVARCHAR(256) NULL,
	[PrincipalId] UNIQUEIDENTIFIER NULL,
	[PrincipalSecret] VARBINARY(256) NULL,
	[PrincipalIdUrl] NVARCHAR(MAX) NULL, 
    [PrincipalSecretUrl] NVARCHAR(MAX) NULL, 
    CONSTRAINT [PK_ServicePrincipals] PRIMARY KEY CLUSTERED ([CredentialId] ASC)
	)
GO
