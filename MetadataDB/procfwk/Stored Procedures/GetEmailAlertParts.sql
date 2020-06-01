CREATE PROCEDURE [procfwk].[GetEmailAlertParts]
	(
	@PipelineId INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ToRecipients NVARCHAR(MAX) = ''
	DECLARE @CcRecipients NVARCHAR(MAX) = ''
	DECLARE @BccRecipients NVARCHAR(MAX) = ''
	DECLARE @EmailSubject NVARCHAR(500)
	DECLARE	@EmailBody NVARCHAR(MAX)
	DECLARE @EmailImportance VARCHAR(5)
	DECLARE @OutcomeBitValue INT

	--map pipeline status to alert outcome bit value
	SELECT
		@OutcomeBitValue = ao.[BitValue]
	FROM
		[procfwk].[CurrentExecution] ce
		INNER JOIN [procfwk].[AlertOutcomes] ao
			ON ce.[PipelineStatus] = ao.[PipelineOutcomeStatus]
	WHERE
		ce.[PipelineId] = @PipelineId;

	--get to recipients
	SELECT
		@ToRecipients += r.[EmailAddress] + ','
	FROM
		[procfwk].[PipelineAlertLink] al
		INNER JOIN [procfwk].[Recipients] r
			ON al.[RecipientId] = r.[RecipientId]
	WHERE
		al.[PipelineId] = @PipelineId
		AND al.[Enabled] = 1
		AND r.[Enabled] = 1
		AND UPPER(r.[MessagePreference]) = 'TO'
		AND (
			al.[OutcomesBitValue] & @OutcomeBitValue <> 0
			OR al.[OutcomesBitValue] & 1 <> 0 --all
			);

	IF (@ToRecipients <> '') SET @ToRecipients = LEFT(@ToRecipients,LEN(@ToRecipients)-1);

	--get cc recipients
	SELECT
		@CcRecipients += r.[EmailAddress] + ','
	FROM
		[procfwk].[PipelineAlertLink] al
		INNER JOIN [procfwk].[Recipients] r
			ON al.[RecipientId] = r.[RecipientId]
	WHERE
		al.[PipelineId] = @PipelineId
		AND al.[Enabled] = 1
		AND r.[Enabled] = 1
		AND UPPER(r.[MessagePreference]) = 'CC'
		AND (
			al.[OutcomesBitValue] & @OutcomeBitValue <> 0
			OR al.[OutcomesBitValue] & 1 <> 0 --all
			);
	
	IF (@CcRecipients <> '') SET @CcRecipients = LEFT(@CcRecipients,LEN(@CcRecipients)-1);

	--get bcc recipients
	SELECT
		@BccRecipients += r.[EmailAddress] + ','
	FROM
		[procfwk].[PipelineAlertLink] al
		INNER JOIN [procfwk].[Recipients] r
			ON al.[RecipientId] = r.[RecipientId]
	WHERE
		al.[PipelineId] = @PipelineId
		AND al.[Enabled] = 1
		AND r.[Enabled] = 1
		AND UPPER(r.[MessagePreference]) = 'BCC'
		AND (
			al.[OutcomesBitValue] & @OutcomeBitValue <> 0
			OR al.[OutcomesBitValue] & 1 <> 0 --all
			);

	IF (@BccRecipients <> '') SET @BccRecipients = LEFT(@BccRecipients,LEN(@BccRecipients)-1);
	
	--get email template
	SELECT
		@EmailBody = [PropertyValue]
	FROM
		[procfwk].[CurrentProperties]
	WHERE
		[PropertyName] = 'EmailAlertBodyTemplate';

	--set subject, body and importance
	SELECT TOP (1)
		--subject
		@EmailSubject = 'ADFprocfwk Alert: ' + [PipelineName] + ' - ' + [PipelineStatus],
	
		--body
		@EmailBody = REPLACE(@EmailBody,'##PipelineName###',[PipelineName]),
		@EmailBody = REPLACE(@EmailBody,'##Status###',[PipelineStatus]),
		@EmailBody = REPLACE(@EmailBody,'##ExecId###',CAST([LocalExecutionId] AS VARCHAR(36))),
		@EmailBody = REPLACE(@EmailBody,'##RunId###',CAST([AdfPipelineRunId] AS VARCHAR(36))),
		@EmailBody = REPLACE(@EmailBody,'##StartDateTime###',CONVERT(VARCHAR(30), [StartDateTime], 120)),
		@EmailBody = CASE
						WHEN [EndDateTime] IS NULL THEN REPLACE(@EmailBody,'##EndDateTime###','N/A')
						ELSE REPLACE(@EmailBody,'##EndDateTime###',CONVERT(VARCHAR(30), [EndDateTime], 120))
					END,
		@EmailBody = CASE
						WHEN [EndDateTime] IS NULL THEN REPLACE(@EmailBody,'##Duration###','N/A')
						ELSE REPLACE(@EmailBody,'##Duration###',CAST(DATEDIFF(MINUTE, [StartDateTime], [EndDateTime]) AS VARCHAR(30)))
					END,
		@EmailBody = REPLACE(@EmailBody,'##CalledByADF###',[CallingDataFactoryName]),
		@EmailBody = REPLACE(@EmailBody,'##ExecutedByADF###',[DataFactoryName]),

		--importance
		@EmailImportance = 
			CASE [PipelineStatus] 
				WHEN 'Success' THEN 'Low'
				WHEN 'Failed' THEN 'High'
				ELSE 'Normal'
			END
	FROM
		[procfwk].[CurrentExecution]
	WHERE
		[PipelineId] = @PipelineId
	ORDER BY
		[StartDateTime] DESC;
	
	--precaution
	IF @EmailBody IS NULL
		SET @EmailBody = 'Internal error. Failed to create profwk email alert body. Execute procedure [procfwk].[GetEmailAlertParts] with pipeline Id: ' + CAST(@PipelineId AS VARCHAR(30)) + ' to debug.';

	--return email parts
	SELECT
		@ToRecipients AS emailRecipients,
		@CcRecipients AS emailCcRecipients,
		@BccRecipients AS emailBccRecipients,
		@EmailSubject AS emailSubject,
		@EmailBody AS emailBody,
		@EmailImportance AS emailImportance;
END;