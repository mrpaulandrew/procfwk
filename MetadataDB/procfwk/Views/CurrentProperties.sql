CREATE VIEW [procfwk].[CurrentProperties]
AS

SELECT
	[PropertyName],
	[PropertyValue]
FROM
	[procfwk].[Properties]
WHERE
	[ValidTo] IS NULL;