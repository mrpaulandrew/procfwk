CREATE   PROCEDURE procfwk.GetPipelineParameters
	(
	@PipelineId INT
	)
AS

SET NOCOUNT ON;

BEGIN

	DECLARE @Json VARCHAR(MAX) = ''

	IF NOT EXISTS
		(
		SELECT * FROM [procfwk].[PipelineParameters] WHERE [PipelineId] = @PipelineId
		)
		BEGIN
			SET @Json = ''
		END
	ELSE
		BEGIN
			SELECT
				@Json += '"' + [ParameterName] + '": "' + [ParameterValue] + '",'
			FROM
				[procfwk].[PipelineParameters]
			WHERE
				[PipelineId] = @PipelineId;

			SET @Json = ',"pipelineParameters": {' + LEFT(@Json,LEN(@Json)-1) + '}'
		END

	SELECT @Json AS 'Params'

END