INSERT [procfwk].[Pipelines]
	(
	[DataFactoryId],
	[StageId],
	[PipelineName], 
	[LogicalPredecessorId],
	[Enabled]
	) 
VALUES 
	(1,1	,'Wait 1'				,NULL		,1),
	(1,1	,'Wait 2'				,NULL		,1),
	(1,1	,'Intentional Error'	,NULL		,1),
	(1,1	,'Wait 3'				,NULL		,1),
	(1,2	,'Wait 4'				,NULL		,1),
	(1,2	,'Wait 5'				,1			,1),
	(1,2	,'Wait 6'				,1			,1),
	(1,2	,'Wait 7'				,NULL		,1),
	(1,3	,'Wait 8'				,1			,1),
	(1,3	,'Wait 9'				,6			,1),
	(1,4	,'Wait 10'				,9			,1)
	;