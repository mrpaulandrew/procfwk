CREATE FUNCTION [procfwkHelpers].[CheckForValidURL] (@Url NVARCHAR(MAX))
RETURNS INT
AS
BEGIN
    DECLARE @Ending VARCHAR(50)
	DECLARE @TempString VARCHAR(50)

	--check URL start
	IF CHARINDEX('https://', @Url) <> 1
    BEGIN
        RETURN 0;
    END

	--check for expected sub domains
    IF CHARINDEX('vault.azure.net', @Url) = 0
    BEGIN
        RETURN 0;
    END

	--check for expected value type
    IF CHARINDEX('secrets', @Url) = 0
    BEGIN
		RETURN 0;
    END
    
	--attempt to check for secret version 
	SELECT 
		@Ending = 
			CASE
				WHEN RIGHT(@Url,1) = '/' THEN REVERSE(LEFT(@Url,LEN(@Url)-1))
				ELSE REVERSE(@Url)
			END,
		@Ending = REVERSE(LEFT(@Ending,CHARINDEX('/',@Ending)-1))

		IF LEN(@Ending) = 32            
		BEGIN            
    		SET @TempString = 
				SUBSTRING(@Ending, 1, 8) + '-' + 
				SUBSTRING(@Ending, 9, 4) + '-' +             
    			SUBSTRING(@Ending, 13, 4) + '-' + 
				SUBSTRING(@Ending, 13, 4) + '-' + 
				SUBSTRING(@Ending, 20, 12)            
		END
	
		IF TRY_CAST(@TempString AS UNIQUEIDENTIFIER) IS NOT NULL 
		BEGIN
			RETURN 0;
		END;

	-- It is a valid URL
    RETURN 1;
END;