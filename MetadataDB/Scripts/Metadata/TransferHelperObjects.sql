IF OBJECT_ID(N'tempdb..#TransferHelperObjects') IS NOT NULL DROP PROCEDURE #TransferHelperObjects;
GO

CREATE PROCEDURE #TransferHelperObjects
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

EXEC #TransferHelperObjects 'AddProperty', 'P';
EXEC #TransferHelperObjects 'GetExecutionDetails', 'P';
EXEC #TransferHelperObjects 'AddRecipientPipelineAlerts', 'P';
EXEC #TransferHelperObjects 'DeleteRecipientAlerts', 'P';
EXEC #TransferHelperObjects 'CheckStageAndPiplineIntegrity', 'P';
EXEC #TransferHelperObjects 'AddPipelineDependant', 'P';
EXEC #TransferHelperObjects 'AddServicePrincipalWrapper', 'P';
EXEC #TransferHelperObjects 'AddServicePrincipalUrls', 'P';
EXEC #TransferHelperObjects 'AddServicePrincipal', 'P';
EXEC #TransferHelperObjects 'DeleteServicePrincipal', 'P';
EXEC #TransferHelperObjects 'CheckForValidURL', 'FN';
EXEC #TransferHelperObjects 'PipelineDependencyChains', 'V';