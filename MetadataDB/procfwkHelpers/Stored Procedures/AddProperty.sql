CREATE PROCEDURE [procfwkHelpers].[AddProperty]
	(
	@PropertyName VARCHAR(128),
	@PropertyValue NVARCHAR(MAX),
	@Description NVARCHAR(MAX) = NULL
	)
AS
BEGIN
	
	SET NOCOUNT ON;

	--defensive check
	IF EXISTS
		(
		SELECT * FROM [procfwk].[Properties] WHERE [PropertyName] = @PropertyName AND [ValidTo] IS NOT NULL
		)
		AND NOT EXISTS
		(
		SELECT * FROM [procfwk].[Properties] WHERE [PropertyName] = @PropertyName AND [ValidTo] IS NULL
		)
		BEGIN
			WITH lastValue AS
				(
				SELECT
					[PropertyId],
					ROW_NUMBER() OVER (PARTITION BY [PropertyName] ORDER BY [ValidTo] ASC) AS Rn
				FROM
					[procfwk].[Properties]
				WHERE
					[PropertyName] = @PropertyName
				)
			--reset property if valid to date has been incorrectly set
			UPDATE
				prop
			SET
				[ValidTo] = NULL
			FROM
				[procfwk].[Properties] prop
				INNER JOIN lastValue
					ON prop.[PropertyId] = lastValue.[PropertyId]
			WHERE
				lastValue.[Rn] = 1
		END
	

	--upsert property
	;WITH sourceTable AS
		(
		SELECT
			@PropertyName AS PropertyName,
			@PropertyValue AS PropertyValue,
			@Description AS [Description],
			GETUTCDATE() AS StartEndDate
		)
	--insert new version of existing property from MERGE OUTPUT
	INSERT INTO [procfwk].[Properties]
		(
		[PropertyName],
		[PropertyValue],
		[Description],
		[ValidFrom]
		)
	SELECT
		[PropertyName],
		[PropertyValue],
		[Description],
		GETUTCDATE()
	FROM
		(
		MERGE INTO
			[procfwk].[Properties] targetTable
		USING
			sourceTable
				ON sourceTable.[PropertyName] = targetTable.[PropertyName]	
		--set valid to date on existing property
		WHEN MATCHED AND [ValidTo] IS NULL THEN 
			UPDATE
			SET
				targetTable.[ValidTo] = sourceTable.[StartEndDate]
		--add new property
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
				(
				[PropertyName],
				[PropertyValue],
				[Description],
				[ValidFrom]
				)
			VALUES
				(
				sourceTable.[PropertyName],
				sourceTable.[PropertyValue],
				sourceTable.[Description],
				sourceTable.[StartEndDate]
				)
			--for new entry of existing record
			OUTPUT
				$action AS [Action],
				sourceTable.*
			) AS MergeOutput
		WHERE
			MergeOutput.[Action] = 'UPDATE';
END;