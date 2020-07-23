EXEC [procfwkHelpers].[AddPipelineDependant]
	@PipelineName = 'Intentional Error',
	@DependantPipelineName = 'Wait 5';

EXEC [procfwkHelpers].[AddPipelineDependant]
	@PipelineName = 'Intentional Error',
	@DependantPipelineName = 'Wait 6';

EXEC [procfwkHelpers].[AddPipelineDependant]
	@PipelineName = 'Wait 6',
	@DependantPipelineName = 'Wait 9';

EXEC [procfwkHelpers].[AddPipelineDependant]
	@PipelineName = 'Wait 9',
	@DependantPipelineName = 'Wait 10';