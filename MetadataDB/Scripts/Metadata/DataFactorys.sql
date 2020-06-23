INSERT INTO [procfwk].[DataFactorys]
	(
	[DataFactoryName],
	[Description],
	[ResourceGroupName]
	)
VALUES
	('FrameworkFactory','Example Data Factory used for development.','ADF.procfwk'),
	('FrameworkFactoryDev','Example Data Factory used for development deployments.','ADF.procfwk'),
	('FrameworkFactoryTest','Example Data Factory used for testing.','ADF.procfwk'),
	('WorkersFactory','Example Data Factory used to house worker pipelines.','ADF.procfwk')
	;