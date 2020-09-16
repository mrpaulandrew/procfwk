# Properties

___
[<< Contents](/ADF.procfwk/contents) / [Database](/ADF.procfwk/database)

___

The properties table within the metadata database controls configuration to support different framework processing behaviour. The table supports value history and should be updated using the [stored procedure](/ADF.procfwk/storedprocedures) __[procfwkHelpers].[AddProperty]__.


## Properties:
___

### OverideRestart	

__Default Value:__ 0	

__Role:__ Should processing not be restarted from the point of failure or should a new execution will be created regardless. 1 = Start New, 0 = Restart. See [framework restarts](/ADF.procfwk/frameworkrestart).

___

### PipelineStatusCheckDuration	

__Default Value:__ 30	

__Role:__ Duration applied to the Wait activity within the Infant [pipeline](/ADF.procfwk/pipelines) Until iterations.

___

### UnknownWorkerResultBlocks	

__Default Value:__ 1	

__Role:__ If a worker pipeline returns an unknown status. Should this block and fail downstream pipeline? 1 = Yes, 0 = No.

___

### CancelledWorkerResultBlocks	

__Default Value:__ 1

__Role:__ If a worker pipeline returns an cancelled status. Should this block and fail downstream pipeline? 1 = Yes, 0 = No.

___

### UseFrameworkEmailAlerting	

__Default Value:__ 1

__Role:__ Do you want the framework to handle pipeline email alerts via the database metadata? 1 = Yes, 0 = No.

___

### EmailAlertBodyTemplate	

__Default Value:__ 
```html
<hr/>
<strong>Pipeline Name: </strong>##PipelineName###<br/>
<strong>Status: </strong>##Status###<br/><br/>
<strong>Execution ID: </strong>##ExecId###<br/>
<strong>Run ID: </strong>##RunId###<br/><br/>
<strong>Start Date Time: </strong>##StartDateTime###<br/>
<strong>End Date Time: </strong>##EndDateTime###<br/>
<strong>Duration (Minutes): </strong>##Duration###<br/><br/>
<strong>Called by Data Factory: </strong>##CalledByADF###<br/>
<strong>Executed by Data Factory: </strong>##ExecutedByADF###<br/>
<hr/>	
```

__Role:__ Basic HTML template of execution information used as the eventual body in [email alerts](/ADF.procfwk/emailalerting) sent.

___

### FailureHandling	

__Accepted Values:__ None, Simple, DependencyChain

__Role:__ Controls processing bahaviour in the event of Worker failures. See [failure handling](/ADF.procfwk/failurehandling).

___

### SPNHandlingMethod	

__Accepted Values:__ StoreInDatabase, StoreInKeyVault. 

__Role:__ Controls how service principal values are stored within the framework. See [SPN Handling](/ADF.procfwk/spnhandling).

___

### ExecutionPrecursorProc	

__Example Value:__ [dbo].[ExampleCustomExecutionPrecursor]	

__Role:__ This procedure will be called first in the parent [pipeline](/ADF.procfwk/pipelines) and can be used to perform/update any required custom behaviour in the framework execution. For example, enable/disable Worker pipelines given a certain run time/day. Invalid proc name values will be ignored.

___