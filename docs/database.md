# Datasbase

___
[<< Contents](/ADF.procfwk/contents) 

* [Properties](/ADF.procfwk/properties)
* [Schemas](/ADF.procfwk/schemas)
* [Tables](/ADF.procfwk/tables)
* [Views](/ADF.procfwk/views)
* [Functions](/ADF.procfwk/dbfunctions)
* [Synonyms](/ADF.procfwk/synonyms)
* [Stored Procedures](/ADF.procfwk/storedprocedures)

___
![SQLDB Icon](/ADF.procfwk/sqldb.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}
The SQL database within the processing framework solution is critical in providing Data Factory with all the metadata required for both runtime configuration and execution of worker pipelines.

It is expected that this resource be made available to [Data Factory](/ADF.procfwk/datafactory) as a [Linked Service](/ADF.procfwk/linkedservices) connection. Beyond that the database itself can be hosted by any type of SQL resource, even using an on-premises SQL Server instance connected via a Hosted IR if needed. That said, for the solution development environment an __Azure SQL Database__ (PaaS offering) is used with an Azure Logical SQL Instance. 

For medium sized implementations (300 worker pipelines across 3 execution stages) of the processing framework it is recommended to start with an __S2__ service tier or equivilant to provide enough compute for all metadata calls made from Data Factory are served in a timely manor and without effecting platform runtime performance. Database storage will greatly depend on the amount of metadata you have and how long you wish to store data in the execution log [tables](/ADF.procfwk/tables).