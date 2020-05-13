CREATE PROCEDURE [dbo].[FailProcedure]
	(
	@RaiseError VARCHAR(50)
	)
AS
BEGIN
	IF(@RaiseError = 'true')
	BEGIN
		RAISERROR('The Stored Procedure intentionally failed.',16,1);
		RETURN 0;
	END
END;