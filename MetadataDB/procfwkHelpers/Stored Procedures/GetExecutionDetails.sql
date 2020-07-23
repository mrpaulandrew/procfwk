CREATE PROCEDURE [procfwkHelpers].[GetExecutionDetails]
	(
	@LocalExecutionId UNIQUEIDENTIFIER = NULL
	)
AS
BEGIN

	--Get last execution ID
	IF @LocalExecutionId IS NULL
	BEGIN
		WITH maxLog AS
			(
			SELECT
				MAX([LogId]) AS MaxLogId
			FROM
				[procfwk].[ExecutionLog]
			)
		SELECT
			@LocalExecutionId = el1.[LocalExecutionId]
		FROM
			[procfwk].[ExecutionLog] el1
			INNER JOIN maxLog
				ON maxLog.[MaxLogId] = el1.[LogId];
	END;

	--Execution Summary
	SELECT
		CAST(el2.[StageId] AS VARCHAR(5)) + ' - ' + stgs.[StageName] AS Stage,
		COUNT(0) AS RecordCount,
		DATEDIFF(MINUTE, MIN(el2.[StartDateTime]), MAX(el2.[EndDateTime])) DurationMinutes
	FROM
		[procfwk].[ExecutionLog] el2
		INNER JOIN [procfwk].[Stages] stgs
			ON el2.[StageId] = stgs.[StageId]
	WHERE
		el2.[LocalExecutionId] = @LocalExecutionId
	GROUP BY
		CAST(el2.[StageId] AS VARCHAR(5)) + ' - ' + stgs.[StageName]
	ORDER BY
		CAST(el2.[StageId] AS VARCHAR(5)) + ' - ' + stgs.[StageName];

	--Full execution details
	SELECT
		el3.[LogId],
		el3.[LocalExecutionId],
		el3.[StageId],
		stgs.[StageName],
		el3.[PipelineId],
		el3.[PipelineName],
		el3.[StartDateTime],
		el3.[EndDateTime],
		ISNULL(DATEDIFF(MINUTE, el3.[StartDateTime], el3.[EndDateTime]),0) AS DurationMinutes,
		el3.[PipelineStatus],
		el3.[AdfPipelineRunId],
		el3.[PipelineParamsUsed],
		errLog.[ActivityRunId],
		errLog.[ActivityName],
		errLog.[ActivityType],
		errLog.[ErrorCode],
		errLog.[ErrorType],
		errLog.[ErrorMessage]
	FROM 
		[procfwk].[ExecutionLog] el3
		LEFT OUTER JOIN [procfwk].[ErrorLog] errLog
			ON el3.[LocalExecutionId] = errLog.[LocalExecutionId]
				AND el3.[AdfPipelineRunId] = errLog.[AdfPipelineRunId]
		INNER JOIN [procfwk].[Stages] stgs
			ON el3.[StageId] = stgs.[StageId]
	WHERE
		el3.[LocalExecutionId] = @LocalExecutionId
	ORDER BY
		el3.[PipelineId],
		el3.[StartDateTime];
END;