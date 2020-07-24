CREATE PROCEDURE [procfwkHelpers].[SetDefaultStages]
AS
BEGIN
	DECLARE @Stages TABLE
		(
		[StageName] [VARCHAR](225) NOT NULL,
		[StageDescription] [VARCHAR](4000) NULL,
		[Enabled] [BIT] NOT NULL
		)
	
	INSERT @Stages
		(
		[StageName], 
		[StageDescription], 
		[Enabled]
		) 
	VALUES 
		('Extract', N'Ingest all data from source systems.', 1),
		('Transform', N'Transform ingested data and apply business logic.', 1),
		('Load', N'Load transformed data into semantic layer.', 1),
		('Serve', N'Load transformed data into semantic layer.', 1);	

	MERGE INTO [procfwk].[Stages] AS tgt
	USING 
		@Stages AS src
			ON tgt.[StageName] = src.[StageName]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[StageDescription] = src.[StageDescription],
			tgt.[Enabled] = src.[Enabled]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[StageName],
			[StageDescription],
			[Enabled]
			)
		VALUES
			(
			src.[StageName],
			src.[StageDescription],
			src.[Enabled]
			)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;	
END;