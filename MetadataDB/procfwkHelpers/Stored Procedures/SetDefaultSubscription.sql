CREATE PROCEDURE [procfwkHelpers].[SetDefaultSubscription]
AS
BEGIN
	DECLARE @Subscriptions TABLE
		(
		[SubscriptionId] UNIQUEIDENTIFIER NOT NULL,
		[Name] NVARCHAR(200) NOT NULL,
		[Description] NVARCHAR(MAX) NULL,
		[TenantId] UNIQUEIDENTIFIER NOT NULL
		)

	INSERT INTO @Subscriptions
		(
		[SubscriptionId],
		[Name],
		[Description],
		[TenantId]
		)
	VALUES
		('12345678-1234-1234-1234-012345678910', 'Default', 'Example value for development environment.', '12345678-1234-1234-1234-012345678910');

	MERGE INTO [procfwk].[Subscriptions] AS tgt
	USING 
		@Subscriptions AS src
			ON tgt.[SubscriptionId] = src.[SubscriptionId]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[Name] = src.[Name],
			tgt.[Description] = src.[Description],
			tgt.[TenantId] = src.[TenantId]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[SubscriptionId],
			[Name],
			[Description],
			[TenantId]
			)
		VALUES
			(
			src.[SubscriptionId],
			src.[Name],
			src.[Description],
			src.[TenantId]
			)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;
END;