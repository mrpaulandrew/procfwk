## Execution Precursor

___
[<< Contents](/procfwk/contents) 

___

The execution precursor allows for custom code/control over the metadata database as part of an execution run. This is done to help environments that, for example, require worker [pipelines](/procfwk/pipelines) to be executed at different intervals/frequencies. The precursor can help you control this by enabling/disabling Worker pipelines using some custom logic. Or do anything to the metadata at runtime using your custom [database](/procfwk/database) objects.

The precursor works by calling the following [stored procedure](/procfwk/storedprocedures) in an activity at the very beginning of the parent [pipeline](/procfwk/pipelines).

__[procfwk].[ExecutePrecursorProcedure]__ - this stored procedure is used by the framework to wrap the execution call to your custom precursor stored procedure. As the framework is calling custom code outside of its normal remit/control the wrapper is used mainly to inform what error message is returned should the custom code fail. The T-SQL within this wrapper is very simple as follows:

```sql
DECLARE @SQL VARCHAR(MAX) 
DECLARE @ErrorDetail NVARCHAR(MAX)

IF OBJECT_ID([procfwk].[GetPropertyValueInternal]('ExecutionPrecursorProc')) IS NOT NULL
	BEGIN
		BEGIN TRY
			SET @SQL = [procfwk].[GetPropertyValueInternal]('ExecutionPrecursorProc');
			EXEC(@SQL);
		END TRY
		BEGIN CATCH
			SELECT
				@ErrorDetail = 'Precursor procedure failed with error: ' + ERROR_MESSAGE();

			RAISERROR(@ErrorDetail,16,1);
		END CATCH
	END;
ELSE
	BEGIN
		PRINT 'Precursor object not found in database.';
	END;
```

From a framework trigger perspective hopefully this can allow a lot more flexiblity for worker pipelines that need to be called on different schedules. But without needing to completely build a scheduling system into the metadata.

## Setting a Precursor Procedure
Added a custom precursor stored procedure to the processing framework is done via the [properties](/procfwk/properties) [table](/procfwk/tables) in the metadata database. The stored procedure itself can be called whatever you want and do whatever you require before a given execution run. The stored procedure name should be set for the value of the property called __ExecutionPrecursorProc__. Or using the following code snippet:

```sql
EXEC [procfwkHelpers].[AddProperty]
	@PropertyName = N'ExecutionPrecursorProc',
	@PropertyValue = N'[dbo].[ExampleCustomExecutionPrecursor]',
```

## Example Precursor Procedure

__[dbo].[ExampleCustomExecutionPrecursor]__ - this procedure is part of the dbo [schema](/procfwk/schemas) and used as a example precursor within my framework development environment. 

___