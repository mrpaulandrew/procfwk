CREATE PROCEDURE [procfwkHelpers].[SetDefaultOrchestrators]
AS
BEGIN
	DECLARE @Orchestrators TABLE 
		(
		[OrchestratorName] NVARCHAR(200) NOT NULL,
		[OrchestratorType] CHAR(3) NOT NULL,
		[ResourceGroupName] NVARCHAR(200) NOT NULL,
		[SubscriptionId] UNIQUEIDENTIFIER NOT NULL,
		[Description] NVARCHAR(MAX) NULL
		)
	
	INSERT INTO @Orchestrators
		(
		[OrchestratorName],
		[OrchestratorType],
		[Description],
		[ResourceGroupName],
		[SubscriptionId]
		)
	VALUES
		('FrameworkFactory','ADF','Example Data Factory used for development.','ADF.procfwk','12345678-1234-1234-1234-012345678910'),
		('FrameworkFactoryDev','ADF','Example Data Factory used for development deployments.','ADF.procfwk','12345678-1234-1234-1234-012345678910'),
		('FrameworkFactoryTest','ADF','Example Data Factory used for testing.','ADF.procfwk','12345678-1234-1234-1234-012345678910'),
		('WorkersFactory','ADF','Example Data Factory used to house worker pipelines.','ADF.procfwk','12345678-1234-1234-1234-012345678910');

	MERGE INTO [procfwk].[Orchestrators] AS tgt
	USING 
		@Orchestrators AS src
			ON tgt.[OrchestratorName] = src.[OrchestratorName]
				AND tgt.[OrchestratorType] = src.[OrchestratorType]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[Description] = src.[Description],
			tgt.[ResourceGroupName] = src.[ResourceGroupName],
			tgt.[SubscriptionId] = src.[SubscriptionId]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[OrchestratorName],
			[OrchestratorType],
			[Description],
			[ResourceGroupName],
			[SubscriptionId]
			)
		VALUES
			(
			src.[OrchestratorName],
			src.[OrchestratorType],
			src.[Description],
			src.[ResourceGroupName],
			src.[SubscriptionId]
			)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;
END;