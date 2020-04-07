CREATE PROCEDURE [dbo].[FailProcedure]
AS

BEGIN

	--default behviour changed to always succeed following the release of v1.2

	SELECT	
		--throw intention error:
		--1 + 'Force error.' AS 'Output'
		
		--fix using:
		1 + '1' AS 'Output'

END