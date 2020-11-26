CREATE PROCEDURE [procfwkHelpers].[DeleteServicePrincipal]
	(
	@OrchestratorName NVARCHAR(200),
	@OrchestratorType CHAR(3),
	@PrincipalIdValue NVARCHAR(256),
	@SpecificPipelineName NVARCHAR(200) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ErrorDetails NVARCHAR(500) = ''
	DECLARE @CredentialId INT

	--resolve principal Id or Url to credential Id
	IF ([procfwk].[GetPropertyValueInternal]('SPNHandlingMethod')) = 'StoreInDatabase'
		BEGIN
			--defensive checks
			BEGIN TRY
				DECLARE @LocalPrincipalId UNIQUEIDENTIFIER

				SELECT --assigned to variable just to supress output of SELECT
					@LocalPrincipalId = CAST(@PrincipalIdValue AS UNIQUEIDENTIFIER)
			END TRY
			BEGIN CATCH
					SET @ErrorDetails = 'Invalid @PrincipalId provided. The format must be a UNIQUEIDENTIFIER.'
					RAISERROR(@ErrorDetails, 16, 1);
					RETURN 0;
			END CATCH	
			
			--get cred id using principal id
			SELECT
				@CredentialId = [CredentialId]
			FROM
				[dbo].[ServicePrincipals]
			WHERE
				[PrincipalId] = @PrincipalIdValue
		END
	ELSE IF ([procfwk].[GetPropertyValueInternal]('SPNHandlingMethod')) = 'StoreInKeyVault'
		BEGIN
			--get cred id using principal id url
			SELECT
				@CredentialId = [CredentialId]
			FROM
				[dbo].[ServicePrincipals]
			WHERE
				[PrincipalIdUrl] = @PrincipalIdValue
		END;
	ELSE
		BEGIN
			RAISERROR('Unknown SPN deletion method.',16,1);
			RETURN 0;
		END;

	--secondary defensive checks
	IF NOT EXISTS
		(
		SELECT [OrchestratorName] FROM [procfwk].[Orchestrators] WHERE [OrchestratorName] = @OrchestratorName AND [OrchestratorType] = @OrchestratorType
		)
		BEGIN
			SET @ErrorDetails = 'Invalid Orchestrator name. Please ensure the Orchestrator metadata exists.'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN 0;
		END

	IF @CredentialId IS NULL
		BEGIN
			SET @ErrorDetails = 'Invalid Service Principal Id Value provided. Please ensure the Service Principal exists.'
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
			
			--delete links
			DELETE
				L
			FROM
				[procfwk].[PipelineAuthLink] L
				INNER JOIN [procfwk].[Pipelines] P
					ON L.[PipelineId] = P.[PipelineId]
				INNER JOIN [procfwk].[Orchestrators] D
					ON P.[OrchestratorId] = D.[OrchestratorId]
						AND L.[OrchestratorId] = D.[OrchestratorId]
				INNER JOIN [dbo].[ServicePrincipals] S
					ON L.[CredentialId] = S.[CredentialId]
			WHERE
				P.[PipelineName] = @SpecificPipelineName
				AND D.[OrchestratorName] = @OrchestratorName
				AND D.[OrchestratorType] = @OrchestratorType
				AND S.[CredentialId] = @CredentialId;
		END
	ELSE
		BEGIN
			--delete links
			DELETE
				L
			FROM
				[procfwk].[PipelineAuthLink] L
				INNER JOIN [procfwk].[Orchestrators] D
					ON L.[OrchestratorId] = D.[OrchestratorId]
				INNER JOIN [dbo].[ServicePrincipals] S
					ON L.[CredentialId] = S.[CredentialId]
			WHERE
				D.[OrchestratorName] = @OrchestratorName
				AND D.[OrchestratorType] = @OrchestratorType
				AND S.[CredentialId] = @CredentialId;
		END

	--finall, delete principal only if not still used by other pipelines
	DELETE 
		SP
	FROM 
		[dbo].[ServicePrincipals] SP
		LEFT OUTER JOIN [procfwk].[PipelineAuthLink] AL
			ON SP.[CredentialId] = AL.[CredentialId]
	WHERE 
		SP.[CredentialId] = @CredentialId
		AND AL.[CredentialId] IS NULL;
END;