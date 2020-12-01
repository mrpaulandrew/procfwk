CREATE PROCEDURE [procfwk].[CheckMetadataIntegrity]
	(
	@DebugMode BIT = 0,
	@BatchName VARCHAR(255) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
	
	/*
	Check 1 - Are there execution stages enabled in the metadata?
	Check 2 - Are there pipelines enabled in the metadata?
	Check 3 - Are there any service principals available to run the processing pipelines?
	Check 4 - Is there at least one TenantId available?
	Check 5 - Is there at least one SubscriptionId available?
	Check 6 - Is there a current OverideRestart property available?
	Check 7 - Are there any enabled pipelines configured without a service principal?
	Check 8 - Are any Orchestrators set to use the default subscription value?
	Check 9 - Are any Subscription set to use the default tenant value?
	Check 10 - Is there a current PipelineStatusCheckDuration property available?
	Check 11 - Is there a current UseFrameworkEmailAlerting property available?
	Check 12 - Is there a current EmailAlertBodyTemplate property available?
	Check 13 - Does the total size of the request body for the pipeline parameters added exceed the Azure Functions size limit when the Worker execute pipeline body is created?
	Check 14 - Is there a current FailureHandling property available?
	Check 15 - Does the FailureHandling property have a valid value?
	Check 16 - When using DependencyChain failure handling, are there any dependants in the same execution stage of the predecessor?
	Check 17 - Does the SPNHandlingMethod property have a valid value?
	Check 18 - Does the Service Principal table contain both types of SPN handling for a single credential?
	Check 19 - Is there a current UseExecutionBatches property available?
	Check 20 - Is there a current FrameworkFactoryResourceGroup property available?
	Check 21 - Is there a current PreviousPipelineRunsQueryRange property available?
	
	--Batch execution checks:
	Check 22 - If using batch executions, is the requested batch name enabled?
	Check 23 - If using batch executions, does the requested batch have links to execution stages?
	Check 24 - Have batch executions been enabled after a none batch execution run?

	Check 25 - Has the execution failed due to an invalid pipeline name? If so, attend to update this before the next run.
	Check 26 - Is there more than one framework orchestrator set?
	Check 27 - Has a framework orchestrator been set for any orchestrators?
	*/

	DECLARE @BatchId UNIQUEIDENTIFIER
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
				'No execution stages are enabled within the metadatabase. Orchestrator has nothing to run.'
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
				'No execution pipelines are enabled within the metadatabase. Orchestrator has nothing to run.'
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
				'No service principal details have been added to the metadata. Orchestrator cannot authorise pipeline executions.'
				)		
		END;

	--Check 4:
	IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[Tenants]
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				4,
				'TenantId value is missing from the [procfwk].[Tenants] table.'
				)		
		END;

	--Check 5:
	IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[Subscriptions]
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				5,
				'SubscriptionId value is missing from the [procfwk].[Subscriptions] table.'
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
	IF EXISTS
		(
		SELECT * FROM [procfwk].[Orchestrators] WHERE [SubscriptionId] = '12345678-1234-1234-1234-012345678910'
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				8,
				'Orchestrator still set to use the default subscription value of 12345678-1234-1234-1234-012345678910.'
				)		
		END;

	--Check 9:
	IF EXISTS
		(
		SELECT * FROM [procfwk].[Subscriptions] WHERE [TenantId] = '12345678-1234-1234-1234-012345678910' AND [SubscriptionId] <> '12345678-1234-1234-1234-012345678910'
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				9,
				'None default subscription still set to use the default tenant value of 12345678-1234-1234-1234-012345678910.'
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
	
	--Check 19:
	IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[CurrentProperties] WHERE [PropertyName] = 'UseExecutionBatches'
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				19,
				'A current UseExecutionBatches value is missing from the properties table.'
				)		
		END;

	--Check 20:
	IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[CurrentProperties] WHERE [PropertyName] = 'FrameworkFactoryResourceGroup'
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				20,
				'A current FrameworkFactoryResourceGroup value is missing from the properties table.'
				)		
		END;

	--Check 21:
	IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[CurrentProperties] WHERE [PropertyName] = 'PreviousPipelineRunsQueryRange'
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				21,
				'A current PreviousPipelineRunsQueryRange value is missing from the properties table.'
				)		
		END;

	--batch execution checks
	IF ([procfwk].[GetPropertyValueInternal]('UseExecutionBatches')) = '1'
		BEGIN			
			IF @BatchName IS NULL
				BEGIN
					RAISERROR('A NULL batch name cannot be passed when the UseExecutionBatches property is set to 1 (true).',16,1);
					RETURN 0;
				END

			SELECT 
				@BatchId = [BatchId]
			FROM
				[procfwk].[Batches]
			WHERE
				[BatchName] = @BatchName;

			--Check 22:
			IF EXISTS
				(
				SELECT 1 FROM [procfwk].[Batches] WHERE [BatchId] = @BatchId AND [Enabled] = 0
				)
				BEGIN
					INSERT INTO @MetadataIntegrityIssues
					VALUES
						( 
						22,
						'The requested execution batch is currently disabled. Enable the batch before proceeding.'
						)
				END;

			--Check 23:
			IF NOT EXISTS
				(
				SELECT 1 FROM [procfwk].[BatchStageLink] WHERE [BatchId] = @BatchId
				)
				BEGIN
					INSERT INTO @MetadataIntegrityIssues
					VALUES
						( 
						23,
						'The requested execution batch does not have any linked execution stages. See table [procfwk].[BatchStageLink] for details.'
						)
				END;

			--Check 24:
			IF EXISTS
				(
				SELECT
					*
				FROM
					[procfwk].[CurrentExecution] c
					LEFT OUTER JOIN [procfwk].[BatchExecution] b
						ON c.[LocalExecutionId] = b.[ExecutionId]
				WHERE
					b.[ExecutionId] IS NULL
				)
				BEGIN
					INSERT INTO @MetadataIntegrityIssues
					VALUES
						( 
						24,
						'Execution records exist in the [procfwk].[CurrentExecution] table that do not have a record in [procfwk].[BatchExecution] table. Has batch excutions been enabed after an incomplete none batch run?'
						)
				END;			
		END; --end batch checks
	
	--Check 25: 
	IF EXISTS
		(
		SELECT 1 FROM [procfwk].[CurrentExecution] WHERE [PipelineStatus] = 'InvalidPipelineNameError'
		)
		BEGIN
			UPDATE
				ce
			SET
				ce.[PipelineName] = p.[PipelineName]
			FROM
				[procfwk].[CurrentExecution] ce
				INNER JOIN [procfwk].[Pipelines] p
					ON ce.[PipelineId] = p.[PipelineId]
						AND ce.[StageId] = p.[StageId]
			WHERE
				ce.[PipelineStatus] = 'InvalidPipelineNameError'
		END;
	
	--Check 26:
	IF (SELECT COUNT(0) FROM [procfwk].[Orchestrators] WHERE [IsFrameworkOrchestrator] = 1) > 1
	BEGIN
		INSERT INTO @MetadataIntegrityIssues
		VALUES
			( 
			26,
			'There is more than one FrameworkOrchestrator set in the table [procfwk].[Orchestrators]. Only one is supported.'
			)		
	END

	--Check 27:
	IF NOT EXISTS
		(
		SELECT 1 FROM [procfwk].[Orchestrators] WHERE [IsFrameworkOrchestrator] = 1
		)
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				27,
				'A FrameworkOrchestrator has not been set in the table [procfwk].[Orchestrators]. Only one is supported.'
				)		
		END

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

	--report issues when in debug mode
	IF @DebugMode = 1
	BEGIN
		IF NOT EXISTS
			(
			SELECT * FROM @MetadataIntegrityIssues
			)
			BEGIN
				PRINT 'No data integrity issues found in metadata.'
				RETURN 0;
			END
		ELSE		
			BEGIN
				SELECT * FROM @MetadataIntegrityIssues;
			END;
	END;
END;
