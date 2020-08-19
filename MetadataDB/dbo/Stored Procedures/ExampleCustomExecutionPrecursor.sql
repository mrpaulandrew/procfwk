CREATE PROCEDURE [dbo].[ExampleCustomExecutionPrecursor]
AS
BEGIN
	
	--set random Worker pipeline parameter wait times for development environment
	;WITH cte AS
		(
		SELECT 
			[PipelineId],
			LEFT(ABS(CAST(CAST(NEWID() AS VARBINARY(192)) AS INT)),2) AS NewValue
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


	--disable certain Workers if running at the weekend...
	-- YOUR CODE HERE

	--enable certain Workers if running on the 10th day of the month...
	-- YOUR CODE HERE

	--disable certain Stages if running on Friday...
	-- YOUR CODE HERE

	--set Worker pipeline parameters to new value based on ______ ....
	-- YOUR CODE HERE
	
	--etc
END;