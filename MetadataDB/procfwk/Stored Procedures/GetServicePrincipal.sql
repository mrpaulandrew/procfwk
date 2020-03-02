CREATE PROCEDURE [procfwk].[GetServicePrincipal]
	(
	@DataFactory NVARCHAR(200),
	@PipelineName NVARCHAR(200)
	)
AS

SET NOCOUNT ON;

BEGIN

	DECLARE @ErrorDetails NVARCHAR(500) = ''

	--defensive checks
	IF NOT EXISTS
		(
		SELECT
			*
		FROM
			[dbo].[ServicePrincipals] S
			INNER JOIN  [procfwk].[PipelineAuthLink] L
				ON S.[CredentialId] = L.[CredentialId]
			INNER JOIN [procfwk].[PipelineProcesses] P
				ON L.[PipelineId] = P.[PipelineId]
			INNER JOIN [procfwk].[DataFactoryDetails] D
				ON P.[DataFactoryId] = D.[DataFactoryId]
					AND L.[DataFactoryId] = D.[DataFactoryId]
		WHERE
			P.[PipelineName] = @PipelineName
			AND D.[DataFactoryName] = @DataFactory
		)
		BEGIN
			SET @ErrorDetails = 'Invalid to find service principal for provided Data Factory and Pipeline name combination.'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN;
		END

	--get auth details
	SELECT
		S.[PrincipalId],
		CAST(DECRYPTBYPASSPHRASE(CONCAT(@DataFactory,@PipelineName), S.[PrincipalSecret]) AS NVARCHAR(MAX)) AS 'Secret'
	FROM
		[dbo].[ServicePrincipals] S
		INNER JOIN  [procfwk].[PipelineAuthLink] L
			ON S.[CredentialId] = L.[CredentialId]
		INNER JOIN [procfwk].[PipelineProcesses] P
			ON L.[PipelineId] = P.[PipelineId]
		INNER JOIN [procfwk].[DataFactoryDetails] D
			ON P.[DataFactoryId] = D.[DataFactoryId]
				AND L.[DataFactoryId] = D.[DataFactoryId]
	WHERE
		P.[PipelineName] = @PipelineName
		AND D.[DataFactoryName] = @DataFactory

END