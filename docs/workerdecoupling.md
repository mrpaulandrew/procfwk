# Worker Pipeline Decoupling

___
[<< Contents](/procfwk/contents) 

___

By design the worker pipelines called by the processing framework can be anywhere;

- Any tenant (see [cross tenant execution](/procfwk/crosstenantexecution)).
- Any subscription.
- Any resource group.
- Any [orchestrator](/procfwk/orchestrators).

Or, simply contained within the same [orchestrator](/procfwk/orchestrators) instance as the framework [pipelines](/procfwk/pipelines) (parent/child/infant).

[ ![](/procfwk/worker-decoupling.png) ](/procfwk/worker-decoupling.png){:target="_blank"}

The Azure [Functions](/procfwk/functions) used to interact with the worker [pipelines](/procfwk/pipelines) assume nothing about the target location and require a complete set of environment metadata provided from the database at runtime. This includes:

- Tenant Id
- Subscription Id
- Resource Group
- Orchestrator Name
- Orchestrator Type
- Pipeline Name
- SPN Id
- SPN Secret

It is this level of pipeline decoupling that allows the processing framework to be used to bootstrap any existing solution.

___