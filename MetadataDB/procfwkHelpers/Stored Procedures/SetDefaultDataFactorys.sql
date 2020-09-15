CREATE PROCEDURE [procfwkHelpers].[SetDefaultDataFactorys]
AS
BEGIN
	DECLARE @DataFactorys TABLE 
		(
		[DataFactoryName] [NVARCHAR](200) NOT NULL,
		[ResourceGroupName] [NVARCHAR](200) NOT NULL,
		[SubscriptionId] UNIQUEIDENTIFIER NOT NULL,
		[Description] [NVARCHAR](MAX) NULL
		)
	
	INSERT INTO @DataFactorys
		(
		[DataFactoryName],
		[Description],
		[ResourceGroupName],
		[SubscriptionId]
		)
	VALUES
		('FrameworkFactory','Example Data Factory used for development.','ADF.procfwk','12345678-1234-1234-1234-012345678910'),
		('FrameworkFactoryDev','Example Data Factory used for development deployments.','ADF.procfwk','12345678-1234-1234-1234-012345678910'),
		('FrameworkFactoryTest','Example Data Factory used for testing.','ADF.procfwk','12345678-1234-1234-1234-012345678910'),
		('WorkersFactory','Example Data Factory used to house worker pipelines.','ADF.procfwk','12345678-1234-1234-1234-012345678910');

	MERGE INTO [procfwk].[DataFactorys] AS tgt
	USING 
		@DataFactorys AS src
			ON tgt.[DataFactoryName] = src.[DataFactoryName]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[Description] = src.[Description],
			tgt.[ResourceGroupName] = src.[ResourceGroupName],
			tgt.[SubscriptionId] = src.[SubscriptionId]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[DataFactoryName],
			[Description],
			[ResourceGroupName],
			[SubscriptionId]
			)
		VALUES
			(
			src.[DataFactoryName],
			src.[Description],
			src.[ResourceGroupName],
			src.[SubscriptionId]
			)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;
END;