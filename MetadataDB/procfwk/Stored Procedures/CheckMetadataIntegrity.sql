CREATE PROCEDURE [procfwk].[CheckMetadataIntegrity]
	(
	@DebugMode BIT = 0
	)
AS

SET NOCOUNT ON;

BEGIN
	
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
	*/

	DECLARE @ErrorDetails VARCHAR(500)
	DECLARE @MetadataIntegrityIssues TABLE
		(
		[CheckNumber] INT NOT NULL,
		[IssuesFound] VARCHAR(MAX) NOT NULL
		)

	--Check 1:
	IF (
		SELECT COUNT(0) FROM [procfwk].[Stages] WHERE [Enabled] = 1
		) = 0
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				1,
				'No execution stages are enabled within the metadatabase. Data Factory has nothing to run.'
				)
		END;

	--Check 2:
	IF (
		SELECT COUNT(0) FROM [procfwk].[Pipelines] WHERE [Enabled] = 1
		) = 0
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				2,
				'No execution pipelines are enabled within the metadatabase. Data Factory has nothing to run.'
				)
		END;

	--Check 3:
	IF
		(
		SELECT COUNT(0) FROM [dbo].[ServicePrincipals]
		) = 0
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
	IF (
		SELECT [PropertyValue] FROM [procfwk].[CurrentProperties] WHERE [PropertyName] = 'TenantId'
		) = '1234-1234-1234-1234-1234'
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				8,
				'Tenant Id property is still set to its default value of 1234-1234-1234-1234-1234.'
				)		
		END;

	--Check 9:
	IF (
		SELECT [PropertyValue] FROM [procfwk].[CurrentProperties] WHERE [PropertyName] = 'SubscriptionId'
		) = '1234-1234-1234-1234-1234'
		BEGIN
			INSERT INTO @MetadataIntegrityIssues
			VALUES
				( 
				9,
				'Subscription Id property is still set to its default value of 1234-1234-1234-1234-1234.'
				)		
		END;

	--throw runtime error if checks fail
	IF EXISTS
		(
		SELECT * FROM @MetadataIntegrityIssues
		)
		AND @DebugMode = 0
		BEGIN
			SET @ErrorDetails = 'Metadata integrity check failed. Run EXEC [procfwk].[CheckMetadataIntegrity] @DebugMode = 1 in debug mode for details.'

			RAISERROR(@ErrorDetails, 16, 1);
			RETURN;
		END

	--report issues when in debug mode
	IF @DebugMode = 1
	BEGIN
		IF NOT EXISTS
			(
			SELECT * FROM @MetadataIntegrityIssues
			)
			PRINT 'No data integrity issues found in metadata.'
		ELSE		
			SELECT * FROM @MetadataIntegrityIssues;
	END;
END