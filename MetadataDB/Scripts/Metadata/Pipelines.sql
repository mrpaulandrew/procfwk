INSERT [procfwk].[PipelineProcesses]
	(
	[StageId], 
	[PipelineName], 
	[Enabled]
	) 
VALUES 
	(1,'Child 1', 1),
	(1,'Child 2', 1),
	(2,'Child 3', 1),
	(2,'Child 4', 1),
	(2,'Child 5', 1),
	(3,'Child 6', 1),
	(3,'Child 7', 0)
	;