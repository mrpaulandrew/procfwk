DECLARE @ActivityMetadata TABLE
	(
	[ActivityName] VARCHAR(128),
	[ActivityDescription] VARCHAR(500),
	[Type] VARCHAR(50)
	)

INSERT INTO @ActivityMetadata ([ActivityName], [ActivityDescription], [Type]) VALUES
	('AzureDataExplorerCommand','Azure Data Explorer Command','External'),
	('AzureFunctionActivity','Azure Function','External'),
	('AzureMLUpdateResource','Azure ML Update Resource','External'),
	('AzureMLBatchExecution','Azure ML Batch Execution','External'),
	('AzureMLExecutePipeline','Azure ML Execute Pipeline','External'),
	('Custom','Custom (Azure Batch)','External'),
	('DatabricksNotebook','Databricks Notebook','External'),
	('DatabricksSparkJar','Databricks Jar','External'),
	('DatabricksSparkPython','Databricks Python','External'),
	('DataLakeAnalyticsU-SQL','U-SQL (Data Lake Analytics)','External'),
	('HDInsightHive','HD Insight Hive','External'),
	('HDInsightMapReduce','HD Insight MapReduce','External'),
	('HDInsightPig','HD Insight Pig','External'),
	('HDInsightSpark','HD Insight Spark','External'),
	('HDInsightStreaming','HD Insight Streaming','External'),
	('SqlServerStoredProcedure','Stored Procedure','External'),
	('WebActivity','Web Activity','External'),
	('SynapseNotebook','Synapse Notebook','External'),
	('SqlPoolStoredProcedure','Synapse SQL Pool Stored Procedure','External'),
	('SparkJob','Synapse Spark Job','External'),
	('AppendVariable','Append Variable','Internal'),
	('Copy','Copy','Internal'),
	('ExecuteDataFlow','Data Flow (Mapping Data Flow)','Internal'),
	('ExecuteWranglingDataflow','Power Query (Wrangling Data Flow)','Internal'),
	('Delete','Delete','Internal'),
	('ExecutePipeline','Execute Pipeline','Internal'),
	('ExecuteSSISPackage','Execute SSIS Package','Internal'),
	('Filter','Filter','Internal'),
	('ForEach','For Each','Internal'),
	('GetMetadata','Get Metadata','Internal'),
	('IfCondition','If Condition','Internal'),
	('Lookup','Lookup','Internal'),
	('SetVariable','Set Variable','Internal'),
	('Switch','Switch','Internal'),
	('Until','Until','Internal'),
	('Validation','Validation','Internal'),
	('Wait','Wait','Internal'),
	('WebHook','Web Hook','Internal')

SELECT * FROM @ActivityMetadata