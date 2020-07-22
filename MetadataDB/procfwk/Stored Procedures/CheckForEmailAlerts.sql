CREATE PROCEDURE [procfwk].[CheckForEmailAlerts]
	(
	@PipelineId INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SendAlerts BIT
	DECLARE @AlertingEnabled BIT

	--get property
	SELECT
		@AlertingEnabled = [procfwk].[GetPropertyValueInternal]('UseFrameworkEmailAlerting');

	--based on global property
	IF (@AlertingEnabled = 1)
		BEGIN
			--based on piplines to recipients link
			IF EXISTS
				(
				SELECT pal.AlertId
				FROM procfwk.CurrentExecution AS ce
				INNER JOIN procfwk.AlertOutcomes AS ao
					ON ao.PipelineOutcomeStatus = ce.PipelineStatus
				INNER JOIN procfwk.PipelineAlertLink AS pal
					ON pal.PipelineId = ce.PipelineId
				INNER JOIN procfwk.Recipients AS r
					ON r.RecipientId = pal.RecipientId
				WHERE ce.PipelineId = @PipelineId
					  AND ao.BitValue & pal.OutcomesBitValue > 0
					  AND pal.[Enabled] = 1
					  AND r.[Enabled] = 1
				)
				BEGIN
					SET @SendAlerts = 1;
				END;
			ELSE
				BEGIN
					SET @SendAlerts = 0;
				END;
		END
	ELSE
		BEGIN
			SET @SendAlerts = 0;
		END;

	SELECT @SendAlerts AS SendAlerts
END;