CREATE PROCEDURE [procfwk].[AddRecipientPipelineAlerts]
	(
	@RecipientName VARCHAR(255),
	@PipelineName NVARCHAR(200) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF @PipelineName IS NOT NULL
		BEGIN
			--add alert for specific pipeline if doesn't exist
			INSERT INTO [procfwk].[PipelineAlertLink]
				(
				[PipelineId],
				[RecipientId]
				)			
			SELECT
				p.[PipelineId],
				r.[RecipientId]
			FROM
				[procfwk].[Pipelines] p
				INNER JOIN [procfwk].[Recipients] r
					ON r.[Name] = @RecipientName
				LEFT OUTER JOIN [procfwk].[PipelineAlertLink] al
					ON p.[PipelineId] = al.[PipelineId]
						AND r.[RecipientId] = al.[RecipientId]
			WHERE
				p.[PipelineName] = @PipelineName
				AND al.[PipelineId] IS NULL
				AND al.[RecipientId] IS NULL;
		END
	ELSE IF @PipelineName IS NULL
		BEGIN
			--remove and re-add alerts for all pipelines
			DELETE 
				al
			FROM 
				[procfwk].[PipelineAlertLink] al
				INNER JOIN [procfwk].[Recipients] r
					ON al.[RecipientId] = r.[RecipientId]
			WHERE
				r.[Name] = @RecipientName;
						
			INSERT INTO [procfwk].[PipelineAlertLink]
				(
				[PipelineId],
				[RecipientId]
				)
			SELECT
				p.[PipelineId],
				r.[RecipientId]
			FROM
				[procfwk].[Recipients] r
				CROSS JOIN [procfwk].[Pipelines] p
			WHERE
				r.[Name] = @RecipientName;
		END;
END;