BEGIN
	IF OBJECT_ID(N'[dbo].[ErrorLogBackup]') IS NOT NULL DROP TABLE [dbo].[ErrorLogBackup];

	SELECT 
		*
	INTO
		[dbo].[ErrorLogBackup]
	FROM
		[procfwk].[ErrorLog];
END;
GO