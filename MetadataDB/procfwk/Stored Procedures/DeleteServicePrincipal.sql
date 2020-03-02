CREATE PROCEDURE [procfwk].[DeleteServicePrincipal]
	(
	@DataFactory NVARCHAR(200),
	@PipelineName NVARCHAR(200),
	@PrincipalId NVARCHAR(256)
	)
AS

SET NOCOUNT ON;

BEGIN

	DECLARE @ErrorDetails NVARCHAR(500) = ''

	--defensive checks
	IF NOT EXISTS
		(
		SELECT [DataFactoryName] FROM [procfwk].[DataFactoryDetails] WHERE [DataFactoryName] = @DataFactory
		)
		BEGIN
			SET @ErrorDetails = 'Invalid Data Factory name. Please ensure the Data Factory metadata exists.'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN;
		END

	IF NOT EXISTS
		( 
		SELECT [PipelineName] FROM [procfwk].[PipelineProcesses] WHERE [PipelineName] = @PipelineName
		)
		BEGIN
			SET @ErrorDetails = 'Invalid Pipeline name. Please ensure the Pipeline metadata exists.'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN;
		END

	IF NOT EXISTS
		(
		SELECT [PrincipalId] FROM [dbo].[ServicePrincipals] WHERE [PrincipalId] = @PrincipalId
		)
		BEGIN
			SET @ErrorDetails = 'Invalid Service Principal Id. Please ensure the Service Principal exists.'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN;
		END

	--delete link
	DELETE
		L
	FROM
		[procfwk].[PipelineAuthLink] L
		INNER JOIN [procfwk].[PipelineProcesses] P
			ON L.[PipelineId] = P.[PipelineId]
		INNER JOIN [procfwk].[DataFactoryDetails] D
			ON P.[DataFactoryId] = D.[DataFactoryId]
				AND L.[DataFactoryId] = D.[DataFactoryId]
		INNER JOIN [dbo].[ServicePrincipals] S
			ON L.[CredentialId] = S.[CredentialId]
	WHERE
		P.[PipelineName] = @PipelineName
		AND D.[DataFactoryName] = @DataFactory
		AND S.[PrincipalId] = @PrincipalId;

	--delete principal
	DELETE FROM [dbo].[ServicePrincipals] WHERE [PrincipalId] = @PrincipalId;

END