IF OBJECT_ID(N'tempdb..#TransferReportingObjects') IS NOT NULL DROP PROCEDURE #TransferReportingObjects;
GO

CREATE PROCEDURE #TransferReportingObjects
	(
	@ObjectName NVARCHAR(128),
	@ObjectType CHAR(2)
	)
AS
BEGIN
	IF EXISTS
		(
		SELECT
			*
		FROM
			sys.objects o
			INNER JOIN sys.schemas s
				ON o.[schema_id] = s.[schema_id]
		WHERE
			o.[Name] = @ObjectName
			AND s.[name] = 'procfwk'
			AND o.[type] = @ObjectType
		)
		BEGIN
			PRINT 'Transferring: ' + @ObjectName;
			EXEC('ALTER SCHEMA [procfwkHelpers] TRANSFER [procfwk].[' + @ObjectName + '];')
		END;
END;
GO

EXEC #TransferReportingObjects 'PipelineDependencyChains', 'V';
