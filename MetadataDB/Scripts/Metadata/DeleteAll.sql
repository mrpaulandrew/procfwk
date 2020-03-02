DELETE FROM [procfwk].[PipelineParameters];
DELETE FROM [procfwk].[PipelineProcesses];
DELETE FROM [procfwk].[DataFactoryDetails];
DELETE FROM [procfwk].[ProcessingStageDetails];

DBCC CHECKIDENT ('[procfwk].[PipelineParameters]', RESEED, 0);
DBCC CHECKIDENT ('[procfwk].[PipelineProcesses]', RESEED, 0);
DBCC CHECKIDENT ('[procfwk].[DataFactoryDetails]', RESEED, 0);
DBCC CHECKIDENT ('[procfwk].[ProcessingStageDetails]', RESEED, 0);