INSERT INTO [procfwk].[Recipients]
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
