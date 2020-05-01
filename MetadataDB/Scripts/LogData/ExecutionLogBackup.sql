IF OBJECT_ID(N'[dbo].[ExecutionLogBackup]') IS NOT NULL DROP TABLE [dbo].[ExecutionLogBackup];

SELECT 
	*
INTO
	[dbo].[ExecutionLogBackup]
FROM
	[procfwk].[ExecutionLog];