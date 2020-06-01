CREATE PROCEDURE [procfwk].[CheckForEmailAlerts]
	(
	@PipelineId INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SendAlerts BIT

	--based on global property
	IF (
		SELECT
			[PropertyValue]
		FROM
			[procfwk].[CurrentProperties]
		WHERE
			[PropertyName] = 'UseFrameworkEmailAlerting'
		) = 0
		BEGIN
			SET @SendAlerts = 0;
		END;
	--based on piplines to recipients link
	ELSE IF EXISTS
		(
		SELECT [PipelineId] FROM [procfwk].[PipelineAlertLink] WHERE [PipelineId] = @PipelineId
		)
		BEGIN
			SET @SendAlerts = 1;
		END;
	ELSE
		BEGIN
			SET @SendAlerts = 0;
		END;

	SELECT @SendAlerts AS SendAlerts
END;