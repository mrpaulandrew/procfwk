# ADF.procfwk - Backlog

[Return to read me...](../master/README.md)
 
## Future Enhancements

| Item | Detail | Status | Version |
|:----:|--------------|--------|--------|
| 1 |Restartability for a failed pipeline executions. | New |  |
| 2 |Stored procedure defensive checking of values passed vs metadata.  | New |  |
| 3 |Performance views for the long term log table. Eg. Average pipeline duration.  | New |  |
| 4 |Add database view for the last execution run using the log table.  | New |  |
| 5 |A better error handler path with actual error details captured.  | New |  |
| 6 |Add a Data Factory metadata table.  | Complete |  |
| 7 |Add a Subscription metadata table.  | New |  |
| 8 |Add Global properties, to include: <ul><li>Tenant Id.</li><li>Subscription Id.</li></ul> | Complete |  |
| 9 |Update the Function activity body to avoid hardcoded authentication details.  | Complete |  |
| 10 |Pre-execution data integrity checks against all metadata.  | New |  |
| 11 |Add email alerting options for pipelines in the event of failures.  | New |  |
| 12 |Create a Power BI dashboard for monitoring large scale solutions.  | New |  |
| 13 |Create a PowerShell script to get and set pipeline processing for a given Data Factory resource.  | New |  |
| 14 |Update the Staging and Pipeline tables to use none sequential numbers for ID’s meaning adhoc stages could later be injected. Eg. 10, 20, 30.  | New |  |
| 15 |Refactor the stored procedures that update the current execution table in a single multi status version.  | New |  |
| 16 |Create a script to pre-populate the stages and pipelines metadata tables.  | New |  |
| 17 |Refactor the Function connectivity client into an Internal Class. | New |  |
| 18 |Add data type handling to the pipeline parameters table.  | New |  |
| x |  | New |  |