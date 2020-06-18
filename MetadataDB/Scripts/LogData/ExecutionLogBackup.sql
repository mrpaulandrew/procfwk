IF OBJECT_ID(N'[dbo].[ExecutionLogBackup]') IS NOT NULL DROP TABLE [dbo].[ExecutionLogBackup];

IF OBJECT_ID(N'[procfwk].[ExecutionLog]') IS NOT NULL --check for new deployments
BEGIN
	SELECT 
		*
	INTO
		[dbo].[ExecutionLogBackup]
	FROM
		[procfwk].[ExecutionLog];
END;