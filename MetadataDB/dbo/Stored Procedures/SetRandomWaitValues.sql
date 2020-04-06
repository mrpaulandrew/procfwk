CREATE PROCEDURE [dbo].[SetRandomWaitValues]
AS
BEGIN

	;WITH cte AS
		(
		SELECT 
			[PipelineId],
			LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)),2) AS 'NewValue'
		FROM 
			[procfwk].[PipelineParameters]
		)

	UPDATE
		pp
	SET
		pp.[ParameterValue] = cte.[NewValue]
	FROM
		[procfwk].[PipelineParameters] pp
		INNER JOIN cte
			ON pp.[PipelineId] = cte.[PipelineId]
		INNER JOIN [procfwk].[Pipelines] p
			ON pp.[PipelineId] = p.[PipelineId]
	WHERE
		p.[PipelineName] LIKE 'Wait%'
		AND p.[Enabled] = 1;

END