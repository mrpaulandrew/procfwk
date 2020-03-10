CREATE PROCEDURE [procfwk].[DeleteServicePrincipal]
	(
	@DataFactory NVARCHAR(200),
	@PrincipalId NVARCHAR(256),
	@SpecificPipelineName NVARCHAR(200) = NULL
	)
AS

SET NOCOUNT ON;

BEGIN

	DECLARE @ErrorDetails NVARCHAR(500) = ''
	DECLARE @LocalPrincipalId UNIQUEIDENTIFIER

	--defensive checks
	BEGIN TRY
		SELECT 
			@LocalPrincipalId = CAST(@PrincipalId AS UNIQUEIDENTIFIER)
	END TRY
	BEGIN CATCH
			SET @ErrorDetails = 'Invalid @PrincipalId provided. The format must be a UNIQUEIDENTIFIER.'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN;
	END CATCH	
	
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
		SELECT [PrincipalId] FROM [dbo].[ServicePrincipals] WHERE [PrincipalId] = @PrincipalId
		)
		BEGIN
			SET @ErrorDetails = 'Invalid Service Principal Id. Please ensure the Service Principal exists.'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN;
		END


	--delete SPN for specific pipeline
	IF @SpecificPipelineName IS NOT NULL
		BEGIN
			IF NOT EXISTS
				( 
				SELECT [PipelineName] FROM [procfwk].[PipelineProcesses] WHERE [PipelineName] = @SpecificPipelineName
				)
				BEGIN
					SET @ErrorDetails = 'Invalid Pipeline name. Please ensure the Pipeline metadata exists.'
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
				P.[PipelineName] = @SpecificPipelineName
				AND D.[DataFactoryName] = @DataFactory
				AND S.[PrincipalId] = @PrincipalId;
		END
	ELSE
		BEGIN
			DELETE
				L
			FROM
				[procfwk].[PipelineAuthLink] L
				INNER JOIN [procfwk].[DataFactoryDetails] D
					ON L.[DataFactoryId] = D.[DataFactoryId]
						AND L.[DataFactoryId] = D.[DataFactoryId]
				INNER JOIN [dbo].[ServicePrincipals] S
					ON L.[CredentialId] = S.[CredentialId]
			WHERE
				D.[DataFactoryName] = @DataFactory
				AND S.[PrincipalId] = @PrincipalId;
		END

	--delete principal only if not still used by other pipelines
	DELETE 
		SP
	FROM 
		[dbo].[ServicePrincipals] SP
		LEFT OUTER JOIN [procfwk].[PipelineAuthLink] AL
			ON SP.[CredentialId] = AL.[CredentialId]
	WHERE 
		SP.[PrincipalId] = @PrincipalId
		AND AL.[CredentialId] IS NULL;

END