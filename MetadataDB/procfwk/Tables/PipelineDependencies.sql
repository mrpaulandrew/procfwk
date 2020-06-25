CREATE TABLE [procfwk].[PipelineDependencies]
	(
	[DependencyId] [INT] IDENTITY(1,1) NOT NULL,
	[PipelineId] [INT] NOT NULL,
	[DependantPipelineId] [INT] NOT NULL,
	CONSTRAINT [PK_PipelineDependencies] PRIMARY KEY CLUSTERED ([DependencyId] ASC),
	CONSTRAINT [FK_PipelineDependencies_Pipelines] FOREIGN KEY([PipelineId]) REFERENCES [procfwk].[Pipelines] ([PipelineId]),
	CONSTRAINT [FK_PipelineDependencies_Pipelines1] FOREIGN KEY([DependantPipelineId]) REFERENCES [procfwk].[Pipelines] ([PipelineId]),
	CONSTRAINT [UK_PipelinesToDependantPipelines] UNIQUE ([PipelineId],[DependantPipelineId]),
	CONSTRAINT [EQ_PipelineIdDependantPipelineId] CHECK ([PipelineId] <> [DependantPipelineId])
	)