CREATE PROCEDURE [procfwk].[DeleteServicePrincipal]
	(
	@DataFactory NVARCHAR(200),
	@PrincipalId NVARCHAR(256),
	@SpecificPipelineName NVARCHAR(200) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ErrorDetails NVARCHAR(500) = ''
	DECLARE @LocalPrincipalId UNIQUEIDENTIFIER

	--defensive checks
	BEGIN TRY
		SELECT --assigned to variable just to supress output of SELECT
			@LocalPrincipalId = CAST(@PrincipalId AS UNIQUEIDENTIFIER)
	END TRY
	BEGIN CATCH
			SET @ErrorDetails = 'Invalid @PrincipalId provided. The format must be a UNIQUEIDENTIFIER.'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN 0;
	END CATCH	
	
	IF NOT EXISTS
		(
		SELECT [DataFactoryName] FROM [procfwk].[DataFactorys] WHERE [DataFactoryName] = @DataFactory
		)
		BEGIN
			SET @ErrorDetails = 'Invalid Data Factory name. Please ensure the Data Factory metadata exists.'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN 0;
		END

	IF NOT EXISTS
		(
		SELECT [PrincipalId] FROM [dbo].[ServicePrincipals] WHERE [PrincipalId] = @PrincipalId
		)
		BEGIN
			SET @ErrorDetails = 'Invalid Service Principal Id. Please ensure the Service Principal exists.'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN 0;
		END


	--delete SPN for specific pipeline
	IF @SpecificPipelineName IS NOT NULL
		BEGIN
			IF NOT EXISTS
				( 
				SELECT [PipelineName] FROM [procfwk].[Pipelines] WHERE [PipelineName] = @SpecificPipelineName
				)
				BEGIN
					SET @ErrorDetails = 'Invalid Pipeline name. Please ensure the Pipeline metadata exists.'
					RAISERROR(@ErrorDetails, 16, 1);
					RETURN 0;
				END
			
			--delete link
			DELETE
				L
			FROM
				[procfwk].[PipelineAuthLink] L
				INNER JOIN [procfwk].[Pipelines] P
					ON L.[PipelineId] = P.[PipelineId]
				INNER JOIN [procfwk].[DataFactorys] D
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
				INNER JOIN [procfwk].[DataFactorys] D
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
END;