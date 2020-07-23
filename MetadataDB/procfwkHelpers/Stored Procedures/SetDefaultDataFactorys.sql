CREATE PROCEDURE [procfwkHelpers].[SetDefaultDataFactorys]
AS
BEGIN
	DECLARE @DataFactorys TABLE 
		(
		[DataFactoryName] [NVARCHAR](200) NOT NULL,
		[ResourceGroupName] [NVARCHAR](200) NOT NULL,
		[Description] [NVARCHAR](MAX) NULL
		)
	
	INSERT INTO @DataFactorys
		(
		[DataFactoryName],
		[Description],
		[ResourceGroupName]
		)
	VALUES
		('FrameworkFactory','Example Data Factory used for development.','ADF.procfwk'),
		('FrameworkFactoryDev','Example Data Factory used for development deployments.','ADF.procfwk'),
		('FrameworkFactoryTest','Example Data Factory used for testing.','ADF.procfwk'),
		('WorkersFactory','Example Data Factory used to house worker pipelines.','ADF.procfwk');

	MERGE INTO [procfwk].[DataFactorys] AS tgt
	USING 
		@DataFactorys AS src
			ON tgt.[DataFactoryName] = src.[DataFactoryName]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[Description] = src.[Description],
			tgt.[ResourceGroupName] = src.[ResourceGroupName]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[DataFactoryName],
			[Description],
			[ResourceGroupName]
			)
		VALUES
			(
			src.[DataFactoryName],
			src.[Description],
			src.[ResourceGroupName]
			)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;
END;