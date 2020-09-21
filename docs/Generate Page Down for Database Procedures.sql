DECLARE @ProcName NVARCHAR(128)
DECLARE @Cursor CURSOR
DECLARE @Page TABLE
	(
	Id INT IDENTITY(1,1) NOT NULL,
	Markdown NVARCHAR(MAX)
	)

SET @Cursor = CURSOR FOR SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.Routines 
WHERE --ROUTINE_NAME = 'AddRecipientPipelineAlerts' AND 
ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_SCHEMA <> 'dbo' ORDER BY ROUTINE_SCHEMA, ROUTINE_NAME

OPEN @Cursor
FETCH NEXT FROM @Cursor INTO @ProcName
WHILE (@@FETCH_STATUS = 0)
BEGIN

	INSERT INTO @Page (Markdown)
	SELECT 
	 '## ' + SO.name AS Markdown			   
	--select *
	FROM 
		sys.objects AS SO
	WHERE
		SO.name = @ProcName
		AND SO.type = 'P'
	UNION ALL SELECT ''
	UNION ALL
	SELECT 
	  '__Schema:__ ' + SCHEMA_NAME(SCHEMA_ID)		   
	FROM 
		sys.objects AS SO
	WHERE
		SO.name = @ProcName
		AND SO.type = 'P'

	IF EXISTS
		(
		SELECT 
			*
		FROM 
			sys.objects AS SO
			INNER JOIN sys.parameters AS P 
				ON SO.OBJECT_ID = P.OBJECT_ID
		WHERE
			SO.name = @ProcName
			AND SO.type = 'P'
		)
		BEGIN
			
			INSERT INTO @Page (Markdown)
			SELECT ''
			
			;WITH cte AS
				(
				SELECT 0 AS Ordering, '|Parameter Name|Data Type|' AS Markdown
				UNION ALL
				SELECT 0, '|---|:---:|'
				UNION ALL
				SELECT 
				  P.parameter_id,
				  '|' + P.name + '|' + TYPE_NAME(P.user_type_id)
				FROM 
					sys.objects AS SO
					INNER JOIN sys.parameters AS P 
						ON SO.OBJECT_ID = P.OBJECT_ID
				WHERE
					SO.name = @ProcName
					AND SO.type = 'P'
				)
			INSERT INTO @Page (Markdown)
			SELECT Markdown FROM cte ORDER BY Ordering
		END

	INSERT INTO @Page (Markdown)
	SELECT ''
	UNION ALL SELECT '__Role:__ Does stuff.'
	UNION ALL SELECT ''
	UNION ALL SELECT '___'
	UNION ALL SELECT ''

	FETCH NEXT FROM @Cursor INTO @ProcName

END

CLOSE @Cursor
DEALLOCATE @Cursor

SELECT * FROM @page