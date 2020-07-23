CREATE PROCEDURE [procfwk].[CheckMetadataIntegrity]
	(
	@DebugMode BIT = 0
	)
AS
BEGIN
	SET NOCOUNT ON;
	
	/*
	Check 1 - Are there execution stages enabled in the metadata?
	Check 2 - Are there pipelines enabled in the metadata?
	Check 3 - Are there any service principals available to run the processing pipelines?
	Check 4 - Is there a current TenantId property available?
	Check 5 - Is there a current SubscriptionId property available?
	Check 6 - Is there a current OverideRestart property available?
	Check 7 - Are there any enabled pipelines configured without a service principal?
	Check 8 - Does the TenantId property still have its default value?
	Check 9 - Does the SubscriptionId property still have its default value?
	Check 10 - Is there a current PipelineStatusCheckDuration property available?
	Check 11 - Is there a current UseFrameworkEmailAlerting property available?
	Check 12 - Is there a current EmailAlertBodyTemplate property available?
	Check 13 - Does the total size of the request body for the pipeline parameters added exceed the Azure Functions size limit when the Worker execute pipeline body is created?
	Check 14 - Is there a current FailureHandling property available?
	Check 15 - Does the FailureHandling property have a valid value?
	Check 16 - When using DependencyChain failure handling, are there any dependants in the same execution stage of the predecessor?
	Check 17 - Does the SPNHandlingMethod property have a valid value?
	Check 18 - Does the Service Principal table contain both types of SPN handling for a single credential?
	---------------------------------------------------------------------------------------------------------------------------------
	Check A: - Are there any Running pipelines that need to be cleaned up?
	*/

	DECLARE @ErrorDetails VARCHAR(500)
	DECLARE @MetadataIntegrityIssues TABLE
		(
		[CheckNumber] INT NOT NULL,
		[IssuesFound] VARCHAR(MAX) NOT NULL
		)

	/*
	Checks:
	*/

	--Check 1:
	IF NOT EXISTS
		(
		SELECT 1 FROM [procfwk].[Stages] WHERE [Enabled] = 1
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				1,
				'No execution stages are enabled within the metadatabase. Data Factory has nothing to run.'
				)
		END;

	--Check 2:
	IF NOT EXISTS
		(
		SELECT 1 FROM [procfwk].[Pipelines] WHERE [Enabled] = 1
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				2,
				'No execution pipelines are enabled within the metadatabase. Data Factory has nothing to run.'
				)
		END;

	--Check 3:
	IF NOT EXISTS 
		(
		SELECT 1 FROM [dbo].[ServicePrincipals]
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				3,
				'No service principal details have been added to the metadata. Data Factory cannot authorise pipeline executions.'
				)		
		END;

	--Check 4:
	IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[CurrentProperties] WHERE [PropertyName] = 'TenantId'
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				4,
				'A current TenantId value is missing from the properties table.'
				)		
		END;

	--Check 5:
	IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[CurrentProperties] WHERE [PropertyName] = 'SubscriptionId'
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				5,
				'A current SubscriptionId value is missing from the properties table.'
				)		
		END;

	--Check 6:
	IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[CurrentProperties] WHERE [PropertyName] = 'OverideRestart'
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				6,
				'A current OverideRestart value is missing from the properties table.'
				)		
		END;

	--Check 7:
	IF EXISTS
		( 
		SELECT 
			* 
		FROM 
			[procfwk].[Pipelines] p 
			LEFT OUTER JOIN [procfwk].[PipelineAuthLink] al 
				ON p.[PipelineId] = al.[PipelineId]
		WHERE
			p.[Enabled] = 1
			AND al.[PipelineId] IS NULL
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				7,
				'Enabled pipelines are missing a valid Service Principal link.'
				)		
		END;

	--Check 8:
	IF ([procfwk].[GetPropertyValueInternal]('TenantId')) = '1234-1234-1234-1234-1234'
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				8,
				'Tenant Id property is still set to its default value of 1234-1234-1234-1234-1234.'
				)		
		END;

	--Check 9:
	IF ([procfwk].[GetPropertyValueInternal]('SubscriptionId')) = '1234-1234-1234-1234-1234'
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				9,
				'Subscription Id property is still set to its default value of 1234-1234-1234-1234-1234.'
				)		
		END;

	--Check 10:
	IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[CurrentProperties] WHERE [PropertyName] = 'PipelineStatusCheckDuration'
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				10,
				'A current PipelineStatusCheckDuration value is missing from the properties table.'
				)		
		END;

	--Check 11:
	IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[CurrentProperties] WHERE [PropertyName] = 'UseFrameworkEmailAlerting'
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				11,
				'A current UseFrameworkEmailAlerting value is missing from the properties table.'
				)		
		END;

	--Check 12:
	IF (
		SELECT
			[PropertyValue]
		FROM
			[procfwk].[CurrentProperties]
		WHERE
			[PropertyName] = 'UseFrameworkEmailAlerting'
		) = 1
		BEGIN
			IF NOT EXISTS
				(
				SELECT * FROM [procfwk].[CurrentProperties] WHERE [PropertyName] = 'EmailAlertBodyTemplate'
				)
				BEGIN
					INSERT INTO @MetadataIntegrityIssues
					VALUES
						( 
						12,
						'A current EmailAlertBodyTemplate value is missing from the properties table.'
						)		
				END;
		END;

	--Check 13:
	IF EXISTS
		(
		SELECT * FROM [procfwk].[PipelineParameterDataSizes] WHERE [Size] > 9
		/*
		Azure Function request limit is 10MB.
		https://docs.microsoft.com/en-us/azure/azure-functions/functions-scale
		9MB to allow for other content in execute pipeline body request.
		*/
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				13,
				'The pipeline parameters entered exceed the Azure Function request body maximum of 10MB. Query view [procfwk].[PipelineParameterDataSizes] for details.'
				)	
		END;

	--Check 14:
	IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[CurrentProperties] WHERE [PropertyName] = 'FailureHandling'
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				14,
				'A current FailureHandling value is missing from the properties table.'
				)		
		END;

	--Check 15:
	IF NOT EXISTS
		(
		SELECT 
			*
		FROM
			[procfwk].[CurrentProperties] 
		WHERE 
			[PropertyName] = 'FailureHandling' 
			AND [PropertyValue] IN ('None','Simple','DependencyChain')
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				15,
				'The property FailureHandling does not have a supported value.'
				)	
		END;

	--Check 16:
	IF ([procfwk].[GetPropertyValueInternal]('FailureHandling')) = 'DependencyChain'
	BEGIN
		IF EXISTS
		(
		SELECT 
			pd.[DependencyId]
		FROM 
			[procfwk].[PipelineDependencies] pd
			INNER JOIN [procfwk].[Pipelines] pp
				ON pd.[PipelineId] = pp.[PipelineId]
			INNER JOIN [procfwk].[Pipelines] dp
				ON pd.[DependantPipelineId] = dp.[PipelineId]
		WHERE
			pp.[StageId] = dp.[StageId]
		)	
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				16,
				'A dependant pipeline and its upstream predecessor exist in the same execution stage. Fix this dependency chain to allow correct failure handling.'
				)	
		END;
	END;

	--Check 17:
	IF NOT EXISTS
		(
		SELECT 
			*
		FROM
			[procfwk].[CurrentProperties] 
		WHERE 
			[PropertyName] = 'SPNHandlingMethod' 
			AND [PropertyValue] IN ('StoreInDatabase','StoreInKeyVault')
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				17,
				'The property SPNHandlingMethod does not have a supported value.'
				)	
		END;

	--Check 18:
	IF EXISTS
		(
		SELECT
			*
		FROM
			[dbo].[ServicePrincipals]
		WHERE
			(
			[PrincipalId] IS NOT NULL
			OR [PrincipalSecret] IS NOT NULL
			)
			AND 
			(
			[PrincipalIdUrl] IS NOT NULL
			OR [PrincipalSecretUrl] IS NOT NULL
			)
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				18,
				'The table [dbo].[ServicePrincipals] can only have one method of SPN details sorted per credential ID.'
				)	
		END;

	/*
	Integrity Checks Outcome:
	*/
	
	--throw runtime error if checks fail
	IF EXISTS
		(
		SELECT * FROM @MetadataIntegrityIssues
		)
		AND @DebugMode = 0
		BEGIN
			SET @ErrorDetails = 'Metadata integrity checks failed. Run EXEC [procfwk].[CheckMetadataIntegrity] @DebugMode = 1; for details.'

			RAISERROR(@ErrorDetails, 16, 1);
			RETURN 0;
		END;

	/*
	Previous Exeuction Checks:
	*/
	
	--Check A:
	IF EXISTS
		(
		SELECT [LocalExecutionId] FROM [procfwk].[CurrentExecution] WHERE [PipelineStatus] NOT IN ('Success','Failed','Blocked') AND [AdfPipelineRunId] IS NOT NULL
		)
		BEGIN
			--return pipelines details that require a clean up
			SELECT 
				[procfwk].[GetPropertyValueInternal]('TenantId') AS TenantId,
				[procfwk].[GetPropertyValueInternal]('SubscriptionId') AS SubscriptionId,
				[ResourceGroupName],
				[DataFactoryName],
				[PipelineName],
				[AdfPipelineRunId],
				[LocalExecutionId],
				[StageId],
				[PipelineId]
			FROM 
				[procfwk].[CurrentExecution]
			WHERE 
				[PipelineStatus] NOT IN ('Success','Failed','Blocked','Cancelled') 
				AND [AdfPipelineRunId] IS NOT NULL
		END;
	ELSE
		BEGIN
			--lookup activity must return something, even if just an empty dataset
			SELECT 
				NULL AS TenantId,
				NULL AS SubscriptionId,
				NULL AS ResourceGroupName,
				NULL AS DataFactoryName,
				NULL AS PipelineName,
				NULL AS AdfPipelineRunId,
				NULL AS LocalExecutionId,
				NULL AS StageId,
				NULL AS PipelineId
			FROM
				[procfwk].[CurrentExecution]
			WHERE
				1 = 2; --ensure no results
		END;

	--report issues when in debug mode
	IF @DebugMode = 1
	BEGIN
		IF NOT EXISTS
			(
			SELECT * FROM @MetadataIntegrityIssues
			)
			BEGIN
				PRINT 'No data integrity issues found in metadata.'
			END
		ELSE		
			BEGIN
				SELECT * FROM @MetadataIntegrityIssues;
			END;
	END;
END;