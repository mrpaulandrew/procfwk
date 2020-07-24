CREATE PROCEDURE [procfwk].[GetServicePrincipal]
	(
	@DataFactory NVARCHAR(200),
	@PipelineName NVARCHAR(200) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Id NVARCHAR(MAX)
	DECLARE @Secret NVARCHAR(MAX)
	DECLARE @TenantId CHAR(36)

	IF ([procfwk].[GetPropertyValueInternal]('SPNHandlingMethod')) = 'StoreInDatabase'
		BEGIN
			--get tenant Id to include in decryption
			SELECT
				@TenantId = [procfwk].[GetPropertyValueInternal]('TenantId');

			--get auth details regardless of being pipeline specific and regardless of a pipeline param being passed
			;WITH cte AS
				(
				SELECT DISTINCT
					S.[PrincipalId] AS Id,
					CAST(DECRYPTBYPASSPHRASE(CONCAT(@TenantId, @DataFactory, @PipelineName), S.[PrincipalSecret]) AS NVARCHAR(MAX)) AS [Secret]
				FROM
					[dbo].[ServicePrincipals] S
					INNER JOIN  [procfwk].[PipelineAuthLink] L
						ON S.[CredentialId] = L.[CredentialId]
					INNER JOIN [procfwk].[Pipelines] P
						ON L.[PipelineId] = P.[PipelineId]
					INNER JOIN [procfwk].[DataFactorys] D
						ON P.[DataFactoryId] = D.[DataFactoryId]
							AND L.[DataFactoryId] = D.[DataFactoryId]
				WHERE
					P.[PipelineName] = @PipelineName
					AND D.[DataFactoryName] = @DataFactory
			
				UNION

				SELECT DISTINCT
					S.[PrincipalId] AS Id,
					CAST(DECRYPTBYPASSPHRASE(CONCAT(@TenantId, @DataFactory), S.[PrincipalSecret]) AS NVARCHAR(MAX)) AS [Secret]
				FROM
					[dbo].[ServicePrincipals] S
					INNER JOIN  [procfwk].[PipelineAuthLink] L
						ON S.[CredentialId] = L.[CredentialId]
					INNER JOIN [procfwk].[DataFactorys] D
						ON L.[DataFactoryId] = D.[DataFactoryId]
							AND L.[DataFactoryId] = D.[DataFactoryId]
				WHERE
					D.[DataFactoryName] = @DataFactory
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
					INNER JOIN [procfwk].[DataFactorys] D
						ON P.[DataFactoryId] = D.[DataFactoryId]
							AND L.[DataFactoryId] = D.[DataFactoryId]
				WHERE
					P.[PipelineName] = @PipelineName
					AND D.[DataFactoryName] = @DataFactory
			
				UNION

				SELECT DISTINCT
					S.[PrincipalIdUrl] AS Id,
					S.[PrincipalSecretUrl] AS [Secret]
				FROM
					[dbo].[ServicePrincipals] S
					INNER JOIN  [procfwk].[PipelineAuthLink] L
						ON S.[CredentialId] = L.[CredentialId]
					INNER JOIN [procfwk].[DataFactorys] D
						ON L.[DataFactoryId] = D.[DataFactoryId]
							AND L.[DataFactoryId] = D.[DataFactoryId]
				WHERE
					D.[DataFactoryName] = @DataFactory
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