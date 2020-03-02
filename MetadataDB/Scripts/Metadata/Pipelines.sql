INSERT [procfwk].[PipelineProcesses]
	(
	[DataFactoryId],
	[StageId],
	[PipelineName], 
	[Enabled]
	) 
VALUES 
	(1,1,'Child 1', 1),
	(1,1,'Child 2', 1),
	(1,2,'Child 3', 1),
	(1,2,'Child 4', 1),
	(1,2,'Child 5', 1),
	(1,3,'Child 6', 1),
	(1,3,'Child 7', 0)
	;