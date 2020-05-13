CREATE PROCEDURE [procfwk].[GetPropertyValue]
	(
	@PropertyName VARCHAR(128)
	)
AS
BEGIN	
	DECLARE @ErrorDetail NVARCHAR(4000) = ''

	--defensive checks
	IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[Properties] WHERE [PropertyName] = @PropertyName
		)
		BEGIN
			SET @ErrorDetail = 'Invalid property name provided. Property does not exist.'
			RAISERROR(@ErrorDetail, 16, 1);
			RETURN 0;
		END
	ELSE IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[Properties] WHERE [PropertyName] = @PropertyName AND [ValidTo] IS NULL
		)
		BEGIN
			SET @ErrorDetail = 'Property name provided does not have a current valid version of the required value.'
			RAISERROR(@ErrorDetail, 16, 1);
			RETURN 0;
		END
	--get valid property value
	ELSE
		BEGIN
			SELECT
				[PropertyValue]
			FROM
				[procfwk].[CurrentProperties]
			WHERE
				[PropertyName] = @PropertyName
		END
END;