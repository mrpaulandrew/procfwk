--PipelineProcesses
IF EXISTS 
	(
	SELECT 
		* 
	FROM 
		sys.objects 
	WHERE 
		[name] = 'PipelineProcesses'
		AND [type] = 'U' --Check for tables as created synonyms to support backwards compatability
	)
	BEGIN
		--drop just to avoid constraints
		IF OBJECT_ID(N'[procfwk].[PipelineParameters]') IS NOT NULL DROP TABLE [procfwk].[PipelineParameters];
		IF OBJECT_ID(N'[procfwk].[PipelineAuthLink]') IS NOT NULL DROP TABLE [procfwk].[PipelineAuthLink];

		DROP TABLE [procfwk].[PipelineProcesses];
	END

--ProcessingStageDetails
IF EXISTS 
	(
	SELECT 
		* 
	FROM 
		sys.objects 
	WHERE 
		[name] = 'ProcessingStageDetails'
		AND [type] = 'U' --Check for tables as created synonyms to support backwards compatability
	)
	BEGIN
		DROP TABLE [procfwk].[ProcessingStageDetails];
	END;

--DataFactoryDetails
IF EXISTS 
	(
	SELECT 
		* 
	FROM 
		sys.objects 
	WHERE 
		[name] = 'DataFactoryDetails'
		AND [type] = 'U' --Check for tables as created synonyms to support backwards compatability
	)
	BEGIN
		DROP TABLE [procfwk].[DataFactoryDetails];
	END;