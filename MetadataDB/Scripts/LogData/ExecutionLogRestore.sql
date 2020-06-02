DECLARE @Columns VARCHAR(MAX) = '';
DECLARE @Values VARCHAR(MAX) = '';
DECLARE @SQL VARCHAR(MAX) = '';

IF EXISTS
	(
	SELECT
		*
	FROM
		sys.objects o
		INNER JOIN sys.schemas s
			ON o.[schema_id] = s.[schema_id]
	WHERE
		o.[name] = 'ExecutionLog'
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
		o.[name] = 'ExecutionLogBackup'
		AND s.[name] = 'dbo'
	)
	BEGIN
		;WITH oldTableColumns AS
			(
			SELECT
				c.[name] AS ColName
			FROM
				sys.objects o
				INNER JOIN sys.schemas s
					ON o.[schema_id] = s.[schema_id]
				INNER JOIN sys.columns c
					ON o.[object_id] = c.[object_id]
			WHERE
				s.[name] = 'dbo'
				AND o.[name] = 'ExecutionLogBackup'
				AND c.[name] <> 'LogId'
			),
			newTableColumns AS
			(
			SELECT
				c.[column_id] AS ColId,
				c.[name] AS ColName
			FROM
				sys.objects o
				INNER JOIN sys.schemas s
					ON o.[schema_id] = s.[schema_id]
				INNER JOIN sys.columns c
					ON o.[object_id] = c.[object_id]
			WHERE
				s.[name] = 'procfwk'
				AND o.[name] = 'ExecutionLog'
				AND c.[name] <> 'LogId'
			)
		SELECT  
			@Columns += QUOTENAME(newTableColumns.[ColName]) + ',' + CHAR(13),
			@Values += ISNULL(QUOTENAME(oldTableColumns.[ColName]),'NULL AS ''' + newTableColumns.[ColName] + '''' ) + ',' + CHAR(13)
		FROM
			newTableColumns 
			LEFT OUTER JOIN oldTableColumns
				ON newTableColumns.[ColName] = oldTableColumns.[ColName];

		SET @Columns = LEFT(@Columns,LEN(@Columns)-2);
		SET @Values = LEFT(@Values,LEN(@Values)-2);

		SET @SQL = 
		'
		INSERT INTO [procfwk].[ExecutionLog]
		(
		' + @Columns + '
		)
		SELECT
		' + @Values + '
		FROM
			[dbo].[ExecutionLogBackup]
		';

		PRINT @SQL;
		EXEC(@SQL);

		DECLARE @Before INT = (SELECT COUNT(0) FROM [dbo].[ExecutionLogBackup]);
		DECLARE @After INT = (SELECT COUNT(0) FROM [procfwk].[ExecutionLog]);

		IF (@Before = @After)
		BEGIN
			DROP TABLE [dbo].[ExecutionLogBackup]
		END;
	END;