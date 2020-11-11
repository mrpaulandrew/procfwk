CREATE PROCEDURE [procfwk].[SetExecutionBlockDependants]
	(
	@ExecutionId UNIQUEIDENTIFIER = NULL,
	@PipelineId INT
	)
AS
BEGIN
	--update dependents status
	UPDATE
		ce
	SET
		ce.[PipelineStatus] = 'Blocked',
		ce.[IsBlocked] = 1
	FROM
		[procfwk].[PipelineDependencies] pe
		INNER JOIN [procfwk].[CurrentExecution] ce
			ON pe.[DependantPipelineId] = ce.[PipelineId]
	WHERE
		ce.[LocalExecutionId] = @ExecutionId
		AND pe.[PipelineId] = @PipelineId
END;