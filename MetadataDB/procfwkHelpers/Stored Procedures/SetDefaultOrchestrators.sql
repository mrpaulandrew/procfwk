CREATE PROCEDURE [procfwkHelpers].[SetDefaultOrchestrators]
AS
BEGIN
	DECLARE @Orchestrators TABLE 
		(
		[OrchestratorName] NVARCHAR(200) NOT NULL,
		[OrchestratorType] CHAR(3) NOT NULL,
		[IsFrameworkOrchestrator] BIT NOT NULL,
		[ResourceGroupName] NVARCHAR(200) NOT NULL,
		[SubscriptionId] UNIQUEIDENTIFIER NOT NULL,
		[Description] NVARCHAR(MAX) NULL
		)
	
	INSERT INTO @Orchestrators
		(
		[OrchestratorName],
		[OrchestratorType],
		[IsFrameworkOrchestrator],
		[Description],
		[ResourceGroupName],
		[SubscriptionId]
		)
	VALUES
		('FrameworkFactory','ADF',1,'Example Data Factory used for development.','ADF.procfwk','12345678-1234-1234-1234-012345678910'),
		('FrameworkFactoryDev','ADF',0,'Example Data Factory used for development deployments.','ADF.procfwk','12345678-1234-1234-1234-012345678910'),
		('FrameworkFactoryTest','ADF',0,'Example Data Factory used for testing.','ADF.procfwk','12345678-1234-1234-1234-012345678910'),
		('WorkersFactory','ADF',0,'Example Data Factory used to house worker pipelines.','ADF.procfwk','12345678-1234-1234-1234-012345678910'),
		('procfwkforsynapse','SYN',0,'Example Synapse instance used to house all pipelines.','ADF.procfwk','12345678-1234-1234-1234-012345678910');

	MERGE INTO [procfwk].[Orchestrators] AS tgt
	USING 
		@Orchestrators AS src
			ON tgt.[OrchestratorName] = src.[OrchestratorName]
				AND tgt.[OrchestratorType] = src.[OrchestratorType]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[IsFrameworkOrchestrator] = src.[IsFrameworkOrchestrator],
			tgt.[Description] = src.[Description],
			tgt.[ResourceGroupName] = src.[ResourceGroupName],
			tgt.[SubscriptionId] = src.[SubscriptionId]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[OrchestratorName],
			[OrchestratorType],
			[IsFrameworkOrchestrator],
			[Description],
			[ResourceGroupName],
			[SubscriptionId]
			)
		VALUES
			(
			src.[OrchestratorName],
			src.[OrchestratorType],
			src.[IsFrameworkOrchestrator],
			src.[Description],
			src.[ResourceGroupName],
			src.[SubscriptionId]
			)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;
END;