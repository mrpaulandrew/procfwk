CREATE PROCEDURE [procfwk].[AddServicePrincipal]
	(
	@DataFactory NVARCHAR(200),
	@PipelineName NVARCHAR(200),
	@PrincipalId NVARCHAR(256),
	@PrincipalSecret NVARCHAR(MAX),
	@PrincipalName NVARCHAR(256) = NULL
	)
AS

SET NOCOUNT ON;

BEGIN

	DECLARE @ErrorDetails NVARCHAR(500) = ''
	DECLARE @CredentialId INT

	--defensive checks
	IF NOT EXISTS
		(
		SELECT [DataFactoryName] FROM [procfwk].[DataFactoryDetails] WHERE [DataFactoryName] = @DataFactory
		)
		BEGIN
			SET @ErrorDetails = 'Invalid Data Factory name. Please ensure the Data Factory metadata exists before trying to add authentication for it.'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN;
		END

	IF NOT EXISTS
		( 
		SELECT [PipelineName] FROM [procfwk].[PipelineProcesses] WHERE [PipelineName] = @PipelineName
		)
		BEGIN
			SET @ErrorDetails = 'Invalid Pipeline name. Please ensure the Pipeline metadata exists before trying to add authentication for it.'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN;
		END

	IF EXISTS
		(
		SELECT [PrincipalId] FROM [dbo].[ServicePrincipals] WHERE [PrincipalId] = @PrincipalId
		)
		BEGIN
			SET @ErrorDetails = 'Service principal Id already exists. If an update is required please delete the existing record using the procedure [procfwk].[DeleteServicePrincipal].'
			RAISERROR(@ErrorDetails, 16, 1);
			RETURN;
		END

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
		ENCRYPTBYPASSPHRASE(CONCAT(@DataFactory,@PipelineName), @PrincipalSecret)

	SET @CredentialId = SCOPE_IDENTITY()

	--add link
	INSERT INTO [procfwk].[PipelineAuthLink]
		(
		[PipelineId],
		[DataFactoryId],
		[CredentialId]
		)
	SELECT
		P.[PipelineId],
		D.[DataFactoryId],
		@CredentialId
	FROM
		[procfwk].[PipelineProcesses] P
		INNER JOIN [procfwk].[DataFactoryDetails] D
			ON P.[DataFactoryId] = D.[DataFactoryId]
	WHERE
		P.[PipelineName] = @PipelineName
		AND D.[DataFactoryName] = @DataFactory;

END