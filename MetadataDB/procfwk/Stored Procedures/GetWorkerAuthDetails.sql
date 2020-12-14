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

	DECLARE @OrchestratorName NVARCHAR(200)
	DECLARE @OrchestratorType CHAR(3)
	DECLARE @PipelineName NVARCHAR(200)

	SELECT 
		@PipelineName = [PipelineName],
		@OrchestratorName = [OrchestratorName],
		@OrchestratorType = [OrchestratorType]
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
					CAST(DECRYPTBYPASSPHRASE(CONCAT(@OrchestratorName, @OrchestratorType, @PipelineName), S.[PrincipalSecret]) AS NVARCHAR(MAX)) AS AppSecret
				FROM
					[dbo].[ServicePrincipals] S
					INNER JOIN  [procfwk].[PipelineAuthLink] L
						ON S.[CredentialId] = L.[CredentialId]
					INNER JOIN [procfwk].[Pipelines] P
						ON L.[PipelineId] = P.[PipelineId]
					INNER JOIN [procfwk].[Orchestrators] D
						ON P.[OrchestratorId] = D.[OrchestratorId]
							AND L.[OrchestratorId] = D.[OrchestratorId]
					INNER JOIN [procfwk].[Subscriptions] Sub
						ON D.[SubscriptionId] = Sub.[SubscriptionId]
				WHERE
					P.[PipelineName] = @PipelineName
					AND D.[OrchestratorName] = @OrchestratorName
					AND D.[OrchestratorType] = @OrchestratorType
			
				UNION

				SELECT DISTINCT
					Sub.[TenantId],
					Sub.[SubscriptionId],					
					S.[PrincipalId] AS AppId,
					CAST(DECRYPTBYPASSPHRASE(CONCAT(@OrchestratorName, @OrchestratorType), S.[PrincipalSecret]) AS NVARCHAR(MAX)) AS AppSecret
				FROM
					[dbo].[ServicePrincipals] S
					INNER JOIN  [procfwk].[PipelineAuthLink] L
						ON S.[CredentialId] = L.[CredentialId]
					INNER JOIN [procfwk].[Orchestrators] D
						ON L.[OrchestratorId] = D.[OrchestratorId]
					INNER JOIN [procfwk].[Subscriptions] Sub
						ON D.[SubscriptionId] = Sub.[SubscriptionId]
				WHERE
					D.[OrchestratorName] = @OrchestratorName
					AND D.[OrchestratorType] = @OrchestratorType
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
					INNER JOIN [procfwk].[Orchestrators] D
						ON P.[OrchestratorId] = D.[OrchestratorId]
							AND L.[OrchestratorId] = D.[OrchestratorId]
					INNER JOIN [procfwk].[Subscriptions] Sub
						ON D.[SubscriptionId] = Sub.[SubscriptionId]
				WHERE
					P.[PipelineName] = @PipelineName
					AND D.[OrchestratorName] = @OrchestratorName
					AND D.[OrchestratorType] = @OrchestratorType
			
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
					INNER JOIN [procfwk].[Orchestrators] D
						ON L.[OrchestratorId] = D.[OrchestratorId]
					INNER JOIN [procfwk].[Subscriptions] Sub
						ON D.[SubscriptionId] = Sub.[SubscriptionId]
				WHERE
					D.[OrchestratorName] = @OrchestratorName
					AND D.[OrchestratorType] = @OrchestratorType
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