CREATE FUNCTION [procfwk].[CheckForValidURL] (@Url NVARCHAR(MAX))
RETURNS INT
AS
BEGIN
    DECLARE @Ending VARCHAR(50)
	DECLARE @TempString VARCHAR(50)

	--check URL start
	IF CHARINDEX('https://', @url) <> 1
    BEGIN
        RETURN 0;
    END

	--check for expected sub domains
    IF CHARINDEX('vault.azure.net', @url) = 0
    BEGIN
        RETURN 0;
    END

	--check for expected value type
    IF CHARINDEX('secrets', @url) = 0
    BEGIN
		RETURN 0;
    END
    
	--attempt to check for secret version 
	SELECT 
		@Ending = 
			CASE
				WHEN RIGHT(@URL,1) = '/' THEN REVERSE(LEFT(@URL,LEN(@URL)-1))
				ELSE REVERSE(@URL)
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