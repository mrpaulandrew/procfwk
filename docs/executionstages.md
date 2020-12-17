# Execution Stages

___
[<< Contents](/procfwk/contents) 

___

An execution stage can be defined as an isolated set of work that the processing framework is given to complete. 

![Stage Pipeline Chain](/procfwk/stage-chain.png)

These sets of work can be considered in the following ways, or defined with these conditions:

* A stage must be set to enabled in the metadata to be called by the processing framework.
* A stage contains one or many lower level worker [pipelines](/procfwk/pipelines).
* All work done within a single execution stage __should not__ have any inter dependencies.
* Work done within a single execution stage will be called in parallel using the framework [scale out processing](/procfwk/scaleoutprocessing) capabilities.
* Worker pipelines with inter dependencies should be added to a subsequent execution stage(s).
* All available execution stages will be processed sequentially.
* The metadata stage ID attribute is used to define the order in which execution stages are processed.
* A given execution stage must complete before the next execution stage can be called.
* Configurable [failure handling](/procfwk/failurehandling) behaviour allows pipelines within an execution stage to fail and still call a subsequent stage.
* The database [stored procedure](/procfwk/storedprocedures) 'GetStages' is used by the parent pipeline to return a distinct, ordered and enabled list of all execution stages in scope for running during a given framework execution run.
* An Azure service level limitation in the pipeline Lookup activity means only 5,000 execution stages can currently be handled by the processing framework. If you require more execution stages, please log a feature request via the GitHub repository issues area, [here](https://github.com/mrpaulandrew/procfwk/issues/new/choose){:target="_blank"}.

___