DELETE FROM [procfwk].[PipelineAuthLink];
DELETE FROM [dbo].[ServicePrincipals];

DELETE FROM [procfwk].[PipelineParameters];
DELETE FROM [procfwk].[PipelineProcesses];
DELETE FROM [procfwk].[DataFactoryDetails];
DELETE FROM [procfwk].[ProcessingStageDetails];

DBCC CHECKIDENT ('[procfwk].[PipelineAuthLink]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[ServicePrincipals]', RESEED, 0);
DBCC CHECKIDENT ('[procfwk].[PipelineParameters]', RESEED, 0);
DBCC CHECKIDENT ('[procfwk].[PipelineProcesses]', RESEED, 0);
DBCC CHECKIDENT ('[procfwk].[DataFactoryDetails]', RESEED, 0);
DBCC CHECKIDENT ('[procfwk].[ProcessingStageDetails]', RESEED, 0);