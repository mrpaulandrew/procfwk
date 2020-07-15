CREATE FUNCTION [procfwk].[GetPropertyValueInternal]
	(
	@PropertyName VARCHAR(128)
	)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @PropertyValue NVARCHAR(MAX)

	SELECT
		@PropertyValue = ISNULL([PropertyValue],'')
	FROM
		[procfwk].[CurrentProperties]
	WHERE
		[PropertyName] = @PropertyName

    RETURN @PropertyValue
END;
