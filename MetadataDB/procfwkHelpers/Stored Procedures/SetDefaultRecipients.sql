CREATE PROCEDURE [procfwkHelpers].[SetDefaultRecipients]
AS
BEGIN
	DECLARE @Recipients TABLE
		(
		[Name] [VARCHAR](255) NULL,
		[EmailAddress] [NVARCHAR](500) NOT NULL,
		[MessagePreference] [CHAR](3) NOT NULL,
		[Enabled] [BIT] NOT NULL
		)

	INSERT INTO @Recipients
		(
		[Name],
		[EmailAddress],
		[MessagePreference],
		[Enabled]
		)
	VALUES
		('Test User 1','test.user1@adfprocfwk.com', 'TO', 1),
		('Test User 2','test.user2@adfprocfwk.com', 'CC', 1),
		('Test User 3','test.user3@adfprocfwk.com', 'BCC', 1);

	MERGE INTO [procfwk].[Recipients] AS tgt
	USING 
		@Recipients AS src
			ON tgt.[Name] = src.[Name]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[EmailAddress] = src.[EmailAddress],
			tgt.[MessagePreference] = src.[MessagePreference],
			tgt.[Enabled] = src.[Enabled]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[Name],
			[EmailAddress],
			[MessagePreference],
			[Enabled]
			)
		VALUES
			(
			src.[Name],
			src.[EmailAddress],
			src.[MessagePreference],
			src.[Enabled]
			)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;	
END;