CREATE VIEW [procfwk].[PipelineParameterDataSizes]
AS

SELECT 
	[PipelineId],
	SUM(
		(CAST(
			DATALENGTH(
				STRING_ESCAPE([ParameterName] + [ParameterValue],'json')) AS DECIMAL)
			/1024) --KB
			/1024 --MB
		) AS Size
FROM 
	[procfwk].[PipelineParameters]
GROUP BY
	[PipelineId];