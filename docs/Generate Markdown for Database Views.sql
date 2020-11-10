DECLARE @ViewName NVARCHAR(128) = 'ServicePrincipals'
DECLARE @Cursor CURSOR
DECLARE @Page TABLE
	(
	Id INT IDENTITY(1,1) NOT NULL,
	Markdown NVARCHAR(MAX)
	)

SET @Cursor = CURSOR FOR SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'VIEW' AND table_schema <> 'sys' ORDER BY TABLE_SCHEMA, table_name

OPEN @Cursor
FETCH NEXT FROM @Cursor INTO @ViewName
WHILE (@@FETCH_STATUS = 0)
BEGIN

	INSERT INTO @Page (Markdown)
	SELECT '## ' + @ViewName AS markdown
	UNION all
	SELECT '__Schema:__ ' + TABLE_SCHEMA FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @ViewName AND TABLE_TYPE = 'VIEW' AND table_schema <> 'sys'
	UNION ALL
	SELECT ''
	UNION ALL
	SELECT '__Role:__ Stores things.'
	UNION ALL
	SELECT ''

	;WITH cte AS
		(
		SELECT 'header' as tablename,0 as colid, '|Id|Attribute|Data Type|Length|Nullable' as markdown
		UNION ALL
		select 'header2' as tablename, 0 as colid, '|:---:|---|---|:---:|:---:|' as markdown
		UNION ALL
		select  o.name as tablename, c.colid, '|' + CONVERT(varchar(10),c.colid) + '|'+c.name+'|'+ t.name +'|' + CASE CONVERT(varchar(10),c.length) WHEN '-1' THEN 'max' ELSE CONVERT(varchar(10),c.length) END + '|' + CASE c.isnullable WHEN 1 THEN 'Yes' ELSE 'No' END as markdown
		from sysobjects o 
		inner join syscolumns c on c.id = o.id
		inner join systypes t on t.xtype = c.xtype
		where o.name = @ViewName
		AND t.name <> 'sysname'
		UNION ALL
		SELECT '',99,''
		UNION ALL
		SELECT '',99,''
		)
	INSERT INTO @Page (Markdown)
	SELECT markdown FROM cte ORDER BY colid

	FETCH NEXT FROM @Cursor INTO @ViewName

END

CLOSE @Cursor
DEALLOCATE @Cursor

SELECT * FROM @page