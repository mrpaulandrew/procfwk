CREATE PROCEDURE [procfwkHelpers].[SetDefaultPipelineParameters]
AS
BEGIN
	DECLARE @PipelineParameters TABLE
		(
		[PipelineId] [INT] NOT NULL,
		[ParameterName] [VARCHAR](128) NOT NULL,
		[ParameterValue] [NVARCHAR](MAX) NULL
		)

	INSERT @PipelineParameters
		(
		[PipelineId], 
		[ParameterName], 
		[ParameterValue]
		) 
	VALUES 
		(1, 'WaitTime', '3'),
		(2, 'WaitTime', '6'),
		(6, 'WaitTime', '9'),
		(4, 'WaitTime', '5'),
		(5, 'WaitTime', '2'),
		(3, 'RaiseErrors', 'false'),
		(3, 'WaitTime', '10'),
		(7, 'WaitTime', '3'),
		(8, 'WaitTime', '5'),
		(9, 'WaitTime', '7'),
		(11, 'WaitTime', '10');

	MERGE INTO [procfwk].[PipelineParameters]  AS tgt
	USING 
		@PipelineParameters AS src
			ON tgt.[PipelineId] = src.[PipelineId]
				AND tgt.[ParameterName] = src.[ParameterName]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[ParameterValue] = src.[ParameterValue]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[PipelineId], 
			[ParameterName], 
			[ParameterValue]
			) 
		VALUES
			(
			src.[PipelineId], 
			src.[ParameterName], 
			src.[ParameterValue]
			) 
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;	
END;