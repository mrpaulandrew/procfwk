INSERT [procfwk].[PipelineProcesses]
	(
	[DataFactoryId],
	[StageId],
	[PipelineName], 
	[Enabled]
	) 
VALUES 
	(1,1,'Wait 1', 1),
	(1,1,'Wait 2', 1),
	(1,1,'Wait 3', 1),
	(1,1,'Wait 4', 1),
	(1,2,'Wait 5', 1),
	(1,2,'Wait 6', 1),
	(1,2,'Wait 7', 1),
	(1,2,'Wait 8', 1),
	(1,2,'Wait 9', 1),
	(1,3,'Wait 10', 1),
	(1,3,'Clean Up', 0)
	;