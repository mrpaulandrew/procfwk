CREATE PROCEDURE [procfwkHelpers].[DeleteMetadataWithoutIntegrity]
AS
BEGIN

	DECLARE @SQL NVARCHAR(MAX) = ''

	;WITH procfwkTables AS
		(
		SELECT
			QUOTENAME(s.[name]) + '.' + QUOTENAME(o.[name]) AS FullName
		FROM
			sys.objects o
			INNER JOIN sys.schemas s
				ON o.[schema_id] = s.[schema_id]
		WHERE
			s.[name] LIKE 'procfwk%'
			AND o.[type] = 'U'

		UNION 

		SELECT
			QUOTENAME(s.[name]) + '.' + QUOTENAME(o.[name]) AS FullName
		FROM
			sys.objects o
			INNER JOIN sys.schemas s
				ON o.[schema_id] = s.[schema_id]
		WHERE
			o.[name] = 'ServicePrincipals'
			AND o.[type] = 'U'
		)

	SELECT --tables must exist or wouldnt appear in sys.objects query
		@SQL += 'DELETE FROM ' + [FullName] + ';' + CHAR(13)
	FROM 
		procfwkTables

	EXEC(@SQL);
END;