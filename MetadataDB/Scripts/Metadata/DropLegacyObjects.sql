IF OBJECT_ID(N'tempdb..#DropLegacyObjects') IS NOT NULL DROP PROCEDURE #DropLegacyObjects;
GO

CREATE PROCEDURE #DropLegacyObjects
	(
	@ObjectName NVARCHAR(128),
	@ObjectType CHAR(2)
	)
AS
BEGIN
	DECLARE @DDLType NVARCHAR(128)

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
			SELECT
				@DDLType = CASE @ObjectType
								WHEN 'P' THEN 'PROCEDURE'
								WHEN 'V' THEN 'VIEW'
								WHEN 'FN' THEN 'FUNCTION'
							END;

			EXEC('DROP ' + @DDLType + ' [procfwk].[' + @ObjectName + '];')
		END;
END;
GO

EXEC #DropLegacyObjects 'AddProperty', 'P';
EXEC #DropLegacyObjects 'GetExecutionDetails', 'P';
EXEC #DropLegacyObjects 'AddRecipientPipelineAlerts', 'P';
EXEC #DropLegacyObjects 'DeleteRecipientAlerts', 'P';
EXEC #DropLegacyObjects 'CheckStageAndPiplineIntegrity', 'P';
EXEC #DropLegacyObjects 'AddPipelineDependant', 'P';
EXEC #DropLegacyObjects 'AddServicePrincipalWrapper', 'P';
EXEC #DropLegacyObjects 'AddServicePrincipalUrls', 'P';
EXEC #DropLegacyObjects 'AddServicePrincipal', 'P';
EXEC #DropLegacyObjects 'DeleteServicePrincipal', 'P';
EXEC #DropLegacyObjects 'CheckForValidURL', 'FN';
EXEC #DropLegacyObjects 'PipelineDependencyChains', 'V';
EXEC #DropLegacyObjects 'AverageStageDuration', 'V';
EXEC #DropLegacyObjects 'CompleteExecutionErrorLog', 'V';
EXEC #DropLegacyObjects 'CompleteExecutionLog', 'V';
EXEC #DropLegacyObjects 'CurrentExecutionSummary', 'V';
EXEC #DropLegacyObjects 'LastExecution', 'V';
EXEC #DropLegacyObjects 'LastExecutionSummary', 'V';
EXEC #DropLegacyObjects 'WorkerParallelismOverTime', 'V';

--replaced with new precursor concept in v1.8.5:
IF OBJECT_ID(N'[dbo].[SetRandomWaitValues]') IS NOT NULL DROP PROCEDURE [dbo].[SetRandomWaitValues];