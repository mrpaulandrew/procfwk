CREATE PROCEDURE [dbo].[FailProcedure]
AS

BEGIN

	SELECT	
		--throw intention error:
		1 + 'Force error.' AS 'Output'
		
		--fix using:
		--1 + '1' AS 'Output'

END