INSERT [procfwk].[Stages]
	(
	[StageName], 
	[StageDescription], 
	[Enabled]
	) 
VALUES 
	('Extract', N'Ingest all data from source systems.', 1),
	('Transform', N'Transform ingested data and apply business logic.', 1),
	('Load', N'Load transformed data into semantic layer.', 1),
	('Serve', N'Load transformed data into semantic layer.', 1)
	;