/*
CREATE USER [##Data Factory Name (Managed Identity)##] 
FROM EXTERNAL PROVIDER;
*/

CREATE ROLE [procfwkuser]
GO

GRANT 
	EXECUTE, 
	SELECT,
	CONTROL,
	ALTER
ON SCHEMA::[procfwk] TO [procfwkuser]
GO

/*
ALTER ROLE [procfwkuser] 
ADD MEMBER [##Data Factory Name (Managed Identity)##];
*/