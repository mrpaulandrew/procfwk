CREATE PROCEDURE [procfwkHelpers].[GetServicePrincipal]
	(
	@OrchestratorName NVARCHAR(200),
	@OrchestratorType CHAR(3),
	@PipelineName NVARCHAR(200) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Id NVARCHAR(MAX)
	DECLARE @Secret NVARCHAR(MAX)

	IF ([procfwk].[GetPropertyValueInternal]('SPNHandlingMethod')) = 'StoreInDatabase'
		BEGIN
			--get auth details regardless of being pipeline specific and regardless of a pipeline param being passed
			;WITH cte AS
				(
				SELECT DISTINCT
					S.[PrincipalId] AS Id,
					CAST(DECRYPTBYPASSPHRASE(CONCAT(@OrchestratorName, @PipelineName), S.[PrincipalSecret]) AS NVARCHAR(MAX)) AS [Secret]
				FROM
					[dbo].[ServicePrincipals] S
					INNER JOIN  [procfwk].[PipelineAuthLink] L
						ON S.[CredentialId] = L.[CredentialId]
					INNER JOIN [procfwk].[Pipelines] P
						ON L.[PipelineId] = P.[PipelineId]
					INNER JOIN [procfwk].[Orchestrators] D
						ON P.[OrchestratorId] = D.[OrchestratorId]
							AND L.[OrchestratorId] = D.[OrchestratorId]
				WHERE
					P.[PipelineName] = @PipelineName
					AND D.[OrchestratorName] = @OrchestratorName
					AND D.[OrchestratorType] = @OrchestratorType
			
				UNION

				SELECT DISTINCT
					S.[PrincipalId] AS Id,
					CAST(DECRYPTBYPASSPHRASE(@OrchestratorName, S.[PrincipalSecret]) AS NVARCHAR(MAX)) AS [Secret]
				FROM
					[dbo].[ServicePrincipals] S
					INNER JOIN  [procfwk].[PipelineAuthLink] L
						ON S.[CredentialId] = L.[CredentialId]
					INNER JOIN [procfwk].[Orchestrators] D
						ON L.[OrchestratorId] = D.[OrchestratorId]
				WHERE
					D.[OrchestratorName] = @OrchestratorName
					AND D.[OrchestratorType] = @OrchestratorType
				)
			SELECT TOP 1
				@Id = [Id],
				@Secret = [Secret]
			FROM
				cte
			WHERE
				[Secret] IS NOT NULL
		END
	ELSE IF ([procfwk].[GetPropertyValueInternal]('SPNHandlingMethod')) = 'StoreInKeyVault'
		BEGIN
			--get auth details regardless of being pipeline specific and regardless of a pipeline param being passed
			;WITH cte AS
				(
				SELECT DISTINCT
					S.[PrincipalIdUrl] AS Id,
					S.[PrincipalSecretUrl] AS [Secret]
				FROM
					[dbo].[ServicePrincipals] S
					INNER JOIN  [procfwk].[PipelineAuthLink] L
						ON S.[CredentialId] = L.[CredentialId]
					INNER JOIN [procfwk].[Pipelines] P
						ON L.[PipelineId] = P.[PipelineId]
					INNER JOIN [procfwk].[Orchestrators] D
						ON P.[OrchestratorId] = D.[OrchestratorId]
							AND L.[OrchestratorId] = D.[OrchestratorId]
				WHERE
					P.[PipelineName] = @PipelineName
					AND D.[OrchestratorName] = @OrchestratorName
					AND D.[OrchestratorType] = @OrchestratorType
			
				UNION

				SELECT DISTINCT
					S.[PrincipalIdUrl] AS Id,
					S.[PrincipalSecretUrl] AS [Secret]
				FROM
					[dbo].[ServicePrincipals] S
					INNER JOIN  [procfwk].[PipelineAuthLink] L
						ON S.[CredentialId] = L.[CredentialId]
					INNER JOIN [procfwk].[Orchestrators] D
						ON L.[OrchestratorId] = D.[OrchestratorId]
				WHERE
					D.[OrchestratorName] = @OrchestratorName
					AND D.[OrchestratorType] = @OrchestratorType
				)
			SELECT TOP 1
				@Id = [Id],
				@Secret = [Secret]
			FROM
				cte
			WHERE
				[Secret] IS NOT NULL
		END
	ELSE
		BEGIN
			RAISERROR('Unknown SPN retrieval method.',16,1);
			RETURN 0;
		END

	--return usable values
	SELECT
		@Id AS Id,
		@Secret AS [Secret]
END;