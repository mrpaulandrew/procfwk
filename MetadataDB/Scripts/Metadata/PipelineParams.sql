INSERT [procfwk].[PipelineParameters] 
	(
	[PipelineId], 
	[ParameterName], 
	[ParameterValue]
	) 
VALUES 
	(1, 'WaitTime', '3'),
	(2, 'WaitTime', '6'),
	(3, 'WaitTime', '9'),
	(4, 'WaitTime', '5'),
	(5, 'WaitTime', '2'),
	(6, 'RaiseErrors', 'false'),
	(6, 'WaitTime', '10'),
	(7, 'WaitTime', '3'),
	(8, 'WaitTime', '5'),
	(9, 'WaitTime', '7'),
	--(10, 'WaitTime', '3'), excluded for functional testing
	(11, 'WaitTime', '10')
	;