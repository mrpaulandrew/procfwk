CREATE VIEW [procfwk].[DataFactorys]
AS
SELECT
	[OrchestratorId] AS DataFactoryId,
	[OrchestratorName] AS DataFactoryName,
	[ResourceGroupName],
	[SubscriptionId],
	[Description]
FROM
	[procfwk].[Orchestrators]
WHERE
	[OrchestratorType] = 'ADF';