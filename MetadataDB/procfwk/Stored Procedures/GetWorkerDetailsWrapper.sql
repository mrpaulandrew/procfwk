CREATE PROCEDURE [procfwk].[GetWorkerDetailsWrapper]
	(
	@ExecutionId UNIQUEIDENTIFIER,
	@StageId INT,
	@PipelineId INT
	)
AS
BEGIN
	/*
	Created this proc just to reduce and refactor the number of pipeline activity 
	calls needed due to the Microsoft enforced limit of 40 activities per pipeline.
	*/
	SET NOCOUNT ON;

	DECLARE @WorkerAuthDetails TABLE
		(
		[tenantId] UNIQUEIDENTIFIER NULL,
		[applicationId] NVARCHAR(MAX) NULL,
		[authenticationKey] NVARCHAR(MAX) NULL,
		[subscriptionId] UNIQUEIDENTIFIER NULL
		)

	DECLARE @WorkerDetails TABLE
		(
		[resourceGroupName] NVARCHAR(200) NULL,
		[orchestratorName] NVARCHAR(200) NULL,
		[orchestratorType] CHAR(3) NULL,
		[pipelineName] NVARCHAR(200) NULL
		)

	--get work auth details
	INSERT INTO @WorkerAuthDetails
		(
		[tenantId],
		[subscriptionId],
		[applicationId],
		[authenticationKey]
		)
	EXEC [procfwk].[GetWorkerAuthDetails]
		@ExecutionId = @ExecutionId,
		@StageId = @StageId,
		@PipelineId = @PipelineId;
	
	--get main worker details
	INSERT INTO @WorkerDetails
		(
		[pipelineName],
		[orchestratorName],
		[orchestratorType],
		[resourceGroupName]
		)
	EXEC [procfwk].[GetWorkerPipelineDetails]
		@ExecutionId = @ExecutionId,
		@StageId = @StageId,
		@PipelineId = @PipelineId;		
	
	--return all details
	SELECT  
		ad.[tenantId],
		ad.[applicationId],
		ad.[authenticationKey],		
		ad.[subscriptionId],
		d.[resourceGroupName],
		d.[orchestratorName],
		d.[orchestratorType],
		d.[pipelineName]
	FROM 
		@WorkerDetails d 
		CROSS JOIN @WorkerAuthDetails ad;
END;