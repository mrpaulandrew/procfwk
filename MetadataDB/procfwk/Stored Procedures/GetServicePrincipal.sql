CREATE PROCEDURE [procfwk].[GetServicePrincipal]
	(
	@DataFactory NVARCHAR(200),
	@PipelineName NVARCHAR(200) = NULL
	)
AS

SET NOCOUNT ON;

BEGIN

	DECLARE @ErrorDetails NVARCHAR(500) = ''
	DECLARE @Id UNIQUEIDENTIFIER
	DECLARE @Secret NVARCHAR(MAX)
	DECLARE @TenantId CHAR(36)

	--get tenant Id to include in decryption
	SELECT
		@TenantId = ISNULL([PropertyValue],'')
	FROM
		[procfwk].[CurrentProperties]
	WHERE
		[PropertyName] = 'TenantId'

	--get auth details regardless of being pipeline specific and regardless of a pipeline param being passed
	;WITH cte AS
		(
		SELECT DISTINCT
			S.[PrincipalId] AS 'Id',
			CAST(DECRYPTBYPASSPHRASE(CONCAT(@TenantId, @DataFactory, @PipelineName), S.[PrincipalSecret]) AS NVARCHAR(MAX)) AS 'Secret'
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
			S.[PrincipalId] AS 'Id',
			CAST(DECRYPTBYPASSPHRASE(CONCAT(@TenantId, @DataFactory), S.[PrincipalSecret]) AS NVARCHAR(MAX)) AS 'Secret'
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
	
	--return usable values
	SELECT
		@Id AS 'Id',
		@Secret AS 'Secret'

END