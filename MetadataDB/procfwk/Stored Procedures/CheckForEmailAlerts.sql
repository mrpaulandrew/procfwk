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
		@AlertingEnabled = [PropertyValue]
	FROM
		[procfwk].[CurrentProperties]
	WHERE
		[PropertyName] = 'UseFrameworkEmailAlerting'

	--based on global property
	IF (@AlertingEnabled = 1)
		BEGIN
			--based on piplines to recipients link
			IF EXISTS
				(
				SELECT 
					al.[AlertId] 
				FROM 
					[procfwk].[PipelineAlertLink] al
					INNER JOIN [procfwk].[Recipients] r
						ON al.[RecipientId] = r.[RecipientId]
				WHERE 
					al.[PipelineId] = @PipelineId
					AND al.[Enabled] = 1
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