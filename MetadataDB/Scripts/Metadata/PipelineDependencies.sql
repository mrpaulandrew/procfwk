EXEC [procfwk].[AddPipelineDependant]
	@PipelineName = 'Intentional Error',
	@DependantPipelineName = 'Wait 5';

EXEC [procfwk].[AddPipelineDependant]
	@PipelineName = 'Intentional Error',
	@DependantPipelineName = 'Wait 6';

EXEC [procfwk].[AddPipelineDependant]
	@PipelineName = 'Wait 6',
	@DependantPipelineName = 'Wait 9';

EXEC [procfwk].[AddPipelineDependant]
	@PipelineName = 'Wait 9',
	@DependantPipelineName = 'Wait 10';