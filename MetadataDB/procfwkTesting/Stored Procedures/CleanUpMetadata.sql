CREATE PROCEDURE [procfwkTesting].[CleanUpMetadata]
AS
BEGIN
	EXEC [procfwkHelpers].[DeleteMetadataWithIntegrity];
	EXEC [procfwkHelpers].[DeleteMetadataWithoutIntegrity];
END;