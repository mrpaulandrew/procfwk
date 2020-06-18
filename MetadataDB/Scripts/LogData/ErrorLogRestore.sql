DECLARE @ErrColumns VARCHAR(MAX) = '';
DECLARE @ErrValues VARCHAR(MAX) = '';
DECLARE @ErrSQL VARCHAR(MAX) = '';

IF EXISTS
	(
	SELECT
		*
	FROM
		sys.objects o
		INNER JOIN sys.schemas s
			ON o.[schema_id] = s.[schema_id]
	WHERE
		o.[name] = 'ErrorLog'
		AND s.[name] = 'procfwk'
	)
	AND EXISTS
	(
	SELECT
		*
	FROM
		sys.objects o
		INNER JOIN sys.schemas s
			ON o.[schema_id] = s.[schema_id]
	WHERE
		o.[name] = 'ErrorLogBackup'
		AND s.[name] = 'dbo'
	)
	BEGIN
		;WITH oldTableColumns AS
			(
			SELECT
				c.[name] AS 'ColName'
			FROM
				sys.objects o
				INNER JOIN sys.schemas s
					ON o.[schema_id] = s.[schema_id]
				INNER JOIN sys.columns c
					ON o.[object_id] = c.[object_id]
			WHERE
				s.[name] = 'dbo'
				AND o.[name] = 'ErrorLogBackup'
				AND c.[name] != 'LogId'
			),
			newTableColumns AS
			(
			SELECT
				c.[column_id] AS 'ColId',
				c.[name] AS 'ColName'
			FROM
				sys.objects o
				INNER JOIN sys.schemas s
					ON o.[schema_id] = s.[schema_id]
				INNER JOIN sys.columns c
					ON o.[object_id] = c.[object_id]
			WHERE
				s.[name] = 'procfwk'
				AND o.[name] = 'ErrorLog'
				AND c.[name] != 'LogId'
			)
		SELECT  
			@ErrColumns += QUOTENAME(newTableColumns.[ColName]) + ',' + CHAR(13),
			@ErrValues += ISNULL(QUOTENAME(oldTableColumns.[ColName]),'NULL AS ''' + newTableColumns.[ColName] + '''' ) + ',' + CHAR(13)
		FROM
			newTableColumns 
			LEFT OUTER JOIN oldTableColumns
				ON newTableColumns.[ColName] = oldTableColumns.[ColName];

		SET @ErrColumns = LEFT(@ErrColumns,LEN(@ErrColumns)-2);
		SET @ErrValues = LEFT(@ErrValues,LEN(@ErrValues)-2);

		SET @ErrSQL = 
		'
		INSERT INTO [procfwk].[ErrorLog]
		(
		' + @ErrColumns + '
		)
		SELECT
		' + @ErrValues + '
		FROM
			[dbo].[ErrorLogBackup]
		';

		PRINT @ErrSQL;
		EXEC(@ErrSQL);

		DECLARE @ErrBefore INT = (SELECT COUNT(0) FROM [dbo].[ErrorLogBackup]);
		DECLARE @ErrAfter INT = (SELECT COUNT(0) FROM [procfwk].[ErrorLog]);

		IF (@ErrBefore = @ErrAfter)
		BEGIN
			DROP TABLE [dbo].[ErrorLogBackup]
		END;
	END