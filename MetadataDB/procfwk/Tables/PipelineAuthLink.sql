CREATE TABLE [procfwk].[PipelineAuthLink](
	[AuthId] [int] IDENTITY(1,1) NOT NULL,
	[PipelineId] [int] NOT NULL,
	[DataFactoryId] [int] NOT NULL,
	[CredentialId] [int] NOT NULL,
	CONSTRAINT [PK_PipelineAuthLink] PRIMARY KEY CLUSTERED ([AuthId] ASC),
	CONSTRAINT [FK_PipelineAuthLink_DataFactoryDetails] FOREIGN KEY([DataFactoryId]) REFERENCES [procfwk].[DataFactoryDetails] ([DataFactoryId]),
	CONSTRAINT [FK_PipelineAuthLink_PipelineProcesses] FOREIGN KEY([PipelineId]) REFERENCES [procfwk].[PipelineProcesses] ([PipelineId]),
	CONSTRAINT [FK_PipelineAuthLink_ServicePrincipals] FOREIGN KEY([CredentialId]) REFERENCES [dbo].[ServicePrincipals] ([CredentialId])
	)