--PipelineProcesses
IF EXISTS 
	(
	SELECT
		* 
	FROM
		sys.objects o
		INNER JOIN sys.schemas s
			ON o.[schema_id] = s.[schema_id]
	WHERE
		o.[name] = 'PipelineProcesses'
		AND s.[name] = 'procfwk'
		AND o.[type] = 'U' --Check for tables as created synonyms to support backwards compatability
	)
	BEGIN
		--drop just to avoid constraints
		IF OBJECT_ID(N'[procfwk].[PipelineParameters]') IS NOT NULL DROP TABLE [procfwk].[PipelineParameters];
		IF OBJECT_ID(N'[procfwk].[PipelineAuthLink]') IS NOT NULL DROP TABLE [procfwk].[PipelineAuthLink];

		SELECT * INTO [dbo].[zz_PipelineProcesses] FROM [procfwk].[PipelineProcesses];

		DROP TABLE [procfwk].[PipelineProcesses];
	END

--ProcessingStageDetails
IF EXISTS 
	(
	SELECT
		* 
	FROM
		sys.objects o
		INNER JOIN sys.schemas s
			ON o.[schema_id] = s.[schema_id]
	WHERE
		o.[name] = 'ProcessingStageDetails'
		AND s.[name] = 'procfwk'
		AND o.[type] = 'U' --Check for tables as created synonyms to support backwards compatability
	)
	BEGIN
		SELECT * INTO [dbo].[zz_ProcessingStageDetails] FROM [procfwk].[ProcessingStageDetails];
		
		DROP TABLE [procfwk].[ProcessingStageDetails];
	END;

--DataFactoryDetails
IF EXISTS 
	(
	SELECT
		* 
	FROM
		sys.objects o
		INNER JOIN sys.schemas s
			ON o.[schema_id] = s.[schema_id]
	WHERE
		o.[name] = 'DataFactoryDetails'
		AND s.[name] = 'procfwk'
		AND o.[type] = 'U' --Check for tables as created synonyms to support backwards compatability
	)
	BEGIN
		SELECT * INTO [dbo].[zz_DataFactoryDetails] FROM [procfwk].[DataFactoryDetails];
		
		DROP TABLE [procfwk].[DataFactoryDetails];
	END;