CREATE PROCEDURE [procfwkHelpers].[AddServicePrincipal]
	(
	@OrchestratorName NVARCHAR(200),
	@OrchestratorType CHAR(3),
	@PrincipalId NVARCHAR(256),
	@PrincipalSecret NVARCHAR(MAX),
	@SpecificPipelineName NVARCHAR(200) = NULL,
	@PrincipalName NVARCHAR(256) = NULL
	)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @ErrorDetails NVARCHAR(500) = ''
	DECLARE @CredentialId INT
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
		SELECT [OrchestratorName] FROM [procfwk].[Orchestrators] WHERE [OrchestratorName] = @OrchestratorName AND [OrchestratorType] = @OrchestratorType
		)
		BEGIN
			SET @ErrorDetails = 'Invalid Orchestrator name. Please ensure the Orchestrator metadata exists before trying to add authentication for it.'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN 0;
		END
	
	IF EXISTS
		(
		SELECT
			*
		FROM
			[procfwk].[PipelineAuthLink] AL
			INNER JOIN [procfwk].[Orchestrators] DF
				ON AL.[OrchestratorId] = DF.[OrchestratorId]
			INNER JOIN [procfwk].[Pipelines] PP
				ON AL.[PipelineId] = PP.[PipelineId]
		WHERE
			DF.[OrchestratorName] = @OrchestratorName
			AND DF.[OrchestratorType] = @OrchestratorType
			AND PP.[PipelineName] = @SpecificPipelineName
		)
		BEGIN
			SET @ErrorDetails = 'The provided Pipeline or Orchestrator combination already have a Service Principal. Delete the existing record using the procedure [procfwk].[DeleteServicePrincipal].'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN 0;
		END
		
	--add SPN for specific pipeline
	IF @SpecificPipelineName IS NOT NULL
		BEGIN
			--secondary defensive check for pipeline optional param
			IF NOT EXISTS
				( 
				SELECT [PipelineName] FROM [procfwk].[Pipelines] WHERE [PipelineName] = @SpecificPipelineName
				)
				BEGIN
					SET @ErrorDetails = 'Invalid Pipeline name. Please ensure the Pipeline metadata exists before trying to add authentication for it.'
					RAISERROR(@ErrorDetails, 16, 1);
					RETURN 0;
				END
			
			--spn may already exist for other pipelines
			IF NOT EXISTS
				(
				SELECT [PrincipalId] FROM [dbo].[ServicePrincipals] WHERE [PrincipalId] = @PrincipalId
				)
				BEGIN
					--add service principal
					INSERT INTO [dbo].[ServicePrincipals]
						( 
						[PrincipalName],
						[PrincipalId],
						[PrincipalSecret]
						)
					SELECT
						ISNULL(@PrincipalName, 'Unknown'),
						@PrincipalId,
						ENCRYPTBYPASSPHRASE(CONCAT(@OrchestratorName, @OrchestratorType, @SpecificPipelineName), @PrincipalSecret)

					SET @CredentialId = SCOPE_IDENTITY()
				END
			ELSE
				BEGIN
					SELECT @CredentialId = [CredentialId] FROM [dbo].[ServicePrincipals] WHERE [PrincipalId] = @PrincipalId
				END

			--add single pipeline to SPN link
			INSERT INTO [procfwk].[PipelineAuthLink]
				(
				[PipelineId],
				[OrchestratorId],
				[CredentialId]
				)
			SELECT
				P.[PipelineId],
				D.[OrchestratorId],
				@CredentialId
			FROM
				[procfwk].[Pipelines] P
				INNER JOIN [procfwk].[Orchestrators] D
					ON P.[OrchestratorId] = D.[OrchestratorId]
			WHERE
				P.[PipelineName] = @SpecificPipelineName
				AND D.[OrchestratorType] = @OrchestratorType
				AND D.[OrchestratorName] = @OrchestratorName;
		END
	ELSE
		--add SPN for all pipelines in Orchestrator
		BEGIN
			--add service principal
			INSERT INTO [dbo].[ServicePrincipals]
				( 
				[PrincipalName],
				[PrincipalId],
				[PrincipalSecret]
				)
			SELECT
				ISNULL(@PrincipalName, 'Unknown'),
				@PrincipalId,
				ENCRYPTBYPASSPHRASE(CONCAT(@OrchestratorName, @OrchestratorType), @PrincipalSecret)

			SET @CredentialId = SCOPE_IDENTITY()

			--add link
			INSERT INTO [procfwk].[PipelineAuthLink]
				(
				[PipelineId],
				[OrchestratorId],
				[CredentialId]
				)
			SELECT
				P.[PipelineId],
				D.[OrchestratorId],
				@CredentialId
			FROM
				[procfwk].[Pipelines] P
				INNER JOIN [procfwk].[Orchestrators] D
					ON P.[OrchestratorId] = D.[OrchestratorId]
				LEFT OUTER JOIN [procfwk].[PipelineAuthLink] L
					ON P.[PipelineId] = L.[PipelineId]
			WHERE
				D.[OrchestratorName] = @OrchestratorName
				AND D.[OrchestratorType] = @OrchestratorType
				AND L.[PipelineId] IS NULL;
		END
END;