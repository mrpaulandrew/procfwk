CREATE PROCEDURE [procfwk].[GetWorkerAuthDetails]
	(
	@ExecutionId UNIQUEIDENTIFIER,
	@StageId INT,
	@PipelineId INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TenId NVARCHAR(MAX)
	DECLARE @SubId NVARCHAR(MAX)
	DECLARE @AppId NVARCHAR(MAX)
	DECLARE @AppSecret NVARCHAR(MAX)

	DECLARE @DataFactory NVARCHAR(200)
	DECLARE @PipelineName NVARCHAR(200)

	SELECT 
		@PipelineName = [PipelineName],
		@DataFactory = [DataFactoryName]
	FROM 
		[procfwk].[CurrentExecution]
	WHERE 
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId;
		

	IF ([procfwk].[GetPropertyValueInternal]('SPNHandlingMethod')) = 'StoreInDatabase'
		BEGIN
			--get auth details regardless of being pipeline specific and regardless of a pipeline param being passed
			;WITH cte AS
				(
				SELECT DISTINCT
					Sub.[TenantId],
					Sub.[SubscriptionId],
					S.[PrincipalId] AS AppId,
					CAST(DECRYPTBYPASSPHRASE(CONCAT(@DataFactory, @PipelineName), S.[PrincipalSecret]) AS NVARCHAR(MAX)) AS AppSecret
				FROM
					[dbo].[ServicePrincipals] S
					INNER JOIN  [procfwk].[PipelineAuthLink] L
						ON S.[CredentialId] = L.[CredentialId]
					INNER JOIN [procfwk].[Pipelines] P
						ON L.[PipelineId] = P.[PipelineId]
					INNER JOIN [procfwk].[DataFactorys] D
						ON P.[DataFactoryId] = D.[DataFactoryId]
							AND L.[DataFactoryId] = D.[DataFactoryId]
					INNER JOIN [procfwk].[Subscriptions] Sub
						ON D.[SubscriptionId] = Sub.[SubscriptionId]
				WHERE
					P.[PipelineName] = @PipelineName
					AND D.[DataFactoryName] = @DataFactory
			
				UNION

				SELECT DISTINCT
					Sub.[TenantId],
					Sub.[SubscriptionId],					
					S.[PrincipalId] AS AppId,
					CAST(DECRYPTBYPASSPHRASE(@DataFactory, S.[PrincipalSecret]) AS NVARCHAR(MAX)) AS AppSecret
				FROM
					[dbo].[ServicePrincipals] S
					INNER JOIN  [procfwk].[PipelineAuthLink] L
						ON S.[CredentialId] = L.[CredentialId]
					INNER JOIN [procfwk].[DataFactorys] D
						ON L.[DataFactoryId] = D.[DataFactoryId]
							AND L.[DataFactoryId] = D.[DataFactoryId]
					INNER JOIN [procfwk].[Subscriptions] Sub
						ON D.[SubscriptionId] = Sub.[SubscriptionId]
				WHERE
					D.[DataFactoryName] = @DataFactory
				)
			SELECT TOP 1
				@TenId = [TenantId],
				@SubId = [SubscriptionId],
				@AppId = [AppId],
				@AppSecret = [AppSecret]
			FROM
				cte
			WHERE
				[AppSecret] IS NOT NULL
		END
	ELSE IF ([procfwk].[GetPropertyValueInternal]('SPNHandlingMethod')) = 'StoreInKeyVault'
		BEGIN
			
			--get auth details regardless of being pipeline specific and regardless of a pipeline param being passed
			;WITH cte AS
				(
				SELECT DISTINCT
					Sub.[TenantId],
					Sub.[SubscriptionId],						
					S.[PrincipalIdUrl] AS AppId,
					S.[PrincipalSecretUrl] AS AppSecret
				FROM
					[dbo].[ServicePrincipals] S
					INNER JOIN  [procfwk].[PipelineAuthLink] L
						ON S.[CredentialId] = L.[CredentialId]
					INNER JOIN [procfwk].[Pipelines] P
						ON L.[PipelineId] = P.[PipelineId]
					INNER JOIN [procfwk].[DataFactorys] D
						ON P.[DataFactoryId] = D.[DataFactoryId]
							AND L.[DataFactoryId] = D.[DataFactoryId]
					INNER JOIN [procfwk].[Subscriptions] Sub
						ON D.[SubscriptionId] = Sub.[SubscriptionId]
				WHERE
					P.[PipelineName] = @PipelineName
					AND D.[DataFactoryName] = @DataFactory
			
				UNION

				SELECT DISTINCT
					Sub.[TenantId],
					Sub.[SubscriptionId],					
					S.[PrincipalIdUrl] AS AppId,
					S.[PrincipalSecretUrl] AS AppSecret
				FROM
					[dbo].[ServicePrincipals] S
					INNER JOIN  [procfwk].[PipelineAuthLink] L
						ON S.[CredentialId] = L.[CredentialId]
					INNER JOIN [procfwk].[DataFactorys] D
						ON L.[DataFactoryId] = D.[DataFactoryId]
							AND L.[DataFactoryId] = D.[DataFactoryId]
					INNER JOIN [procfwk].[Subscriptions] Sub
						ON D.[SubscriptionId] = Sub.[SubscriptionId]
				WHERE
					D.[DataFactoryName] = @DataFactory
				)
			SELECT TOP 1
				@TenId = [TenantId],
				@SubId = [SubscriptionId],
				@AppId = [AppId],
				@AppSecret = [AppSecret]
			FROM
				cte
			WHERE
				[AppSecret] IS NOT NULL
		END
	ELSE
		BEGIN
			RAISERROR('Unknown SPN retrieval method.',16,1);
			RETURN 0;
		END

	--return usable values
	SELECT
		@TenId AS TenantId,
		@SubId AS SubscriptionId,
		@AppId AS AppId,
		@AppSecret AS AppSecret
END;