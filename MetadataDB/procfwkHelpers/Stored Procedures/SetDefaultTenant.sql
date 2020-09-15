CREATE PROCEDURE [procfwkHelpers].[SetDefaultTenant]
AS
BEGIN
	DECLARE @Tenants TABLE
		(
		[TenantId] UNIQUEIDENTIFIER NOT NULL,
		[Name] NVARCHAR(200) NOT NULL,
		[Description] NVARCHAR(MAX) NULL
		)

	INSERT INTO @Tenants
		(
		[TenantId],
		[Name],
		[Description]
		)
	VALUES
		('12345678-1234-1234-1234-012345678910', 'Default', 'Example value for development environment.');

	MERGE INTO [procfwk].[Tenants] AS tgt
	USING 
		@Tenants AS src
			ON tgt.[TenantId] = src.[TenantId]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[Name] = src.[Name],
			tgt.[Description] = src.[Description]		
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[TenantId],
			[Name],
			[Description]
			)
		VALUES
			(
			src.[TenantId],
			src.[Name],
			src.[Description]
			)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;
END;