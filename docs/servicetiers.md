# Service Tiers

___
[<< Contents](/procfwk/contents) 

___

When deploying Azure resources always check with the person paying the bill!

In the case of the processing framework, the intention is to keep resources running as cheaply as possible. That said, the following is expected in terms of service tiers.

| Resource | Tier |Comments |
|:----:|:----:|----|
|Data Factory | v2 | Data Flow activities are not used as part of the processing framework so the default auto resolving Azure Integration Runtime can be used. |
| SQL Database | S2 |Using a provisioned service tier rather than serverless is recommended to avoid framework start up failures.  |
| Functions App | Consumption Plan |Deployments done using code to a Windows host wit support for .Net Core 3.1  |
| Key Vault | Standard |Optional.  |

The above service tiers have been bench marked running 300 worker pipelines, across 3 [execution stages](/procfwk/executionstages) and 600 worker pipelines in two concurrent [batches](/procfwk/executionbatches).
