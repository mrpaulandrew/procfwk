CREATE ROLE [procfwkuser]
GO

GRANT 
	EXECUTE, 
	SELECT,
	CONTROL,
	ALTER
ON SCHEMA::[procfwk] TO [procfwkuser]
GO