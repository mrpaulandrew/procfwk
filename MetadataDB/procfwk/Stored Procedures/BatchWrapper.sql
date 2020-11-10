CREATE PROCEDURE [procfwk].[BatchWrapper]
AS
BEGIN
	IF([procfwk].[GetPropertyValueInternal]('UseExecutionBatches')) = '0'
	BEGIN
		
		PRINT 'Not using batches.'

	END
	ELSE IF ([procfwk].[GetPropertyValueInternal]('UseExecutionBatches')) = '1'
	BEGIN

		PRINT 'Using batches.'

	END
	ELSE
	BEGIN
		RAISERROR('Unknown batch handling configuration. Update properties with UseExecutionBatches value and try again.',16,1);
		RETURN 0;
	END
END;