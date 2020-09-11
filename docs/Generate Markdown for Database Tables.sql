DECLARE @TableName NVARCHAR(128) = 'ServicePrincipals'
DECLARE @Cursor CURSOR
DECLARE @Page TABLE
	(
	Id INT IDENTITY(1,1) NOT NULL,
	Markdown NVARCHAR(MAX)
	)

SET @Cursor = CURSOR FOR SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND table_name <> 'sysdiagrams' ORDER BY table_name

OPEN @Cursor
FETCH NEXT FROM @Cursor INTO @TableName
WHILE (@@FETCH_STATUS = 0)
BEGIN

	INSERT INTO @Page (Markdown)
	SELECT '## ' + @TableName AS markdown
	UNION all
	SELECT '__Schema:__ ' + name FROM sys.schemas WHERE [SCHEMA_ID] = (SELECT SCHEMA_ID FROM sys.objects WHERE NAME = @TableName)
	UNION ALL
	SELECT ''
	UNION ALL
	SELECT '__Definition:__ Stores things.'
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
		where o.name = @TableName
		AND t.name <> 'sysname'
		UNION ALL
		SELECT '',99,''
		UNION ALL
		SELECT '',99,''
		)
	INSERT INTO @Page (Markdown)
	SELECT markdown FROM cte ORDER BY colid

	FETCH NEXT FROM @Cursor INTO @TableName

END

CLOSE @Cursor
DEALLOCATE @Cursor

SELECT * FROM @page