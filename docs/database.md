# Database

___
[<< Contents](/procfwk/contents) 

* [Properties](/procfwk/properties)
* [Schemas](/procfwk/schemas)
* [Tables](/procfwk/tables)
* [Views](/procfwk/views)
* [Functions](/procfwk/dbfunctions)
* [Synonyms](/procfwk/synonyms)
* [Stored Procedures](/procfwk/storedprocedures)

___
![SQLDB Icon](/procfwk/sqldb.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}
The SQL database within the processing framework solution is critical in providing the [orchestrator](/procfwk/orchestrators) with all the metadata required for both runtime configuration and execution of worker pipelines.

It is expected that this resource be made available to the [orchestrator](/procfwk/orchestrators) as a [Linked Service](/procfwk/linkedservices) connection. Beyond that the database itself can be hosted by any type of SQL resource, even using an on-premises SQL Server instance connected via a Hosted IR if needed. That said, for the solution development environment an __Azure SQL Database__ (PaaS offering) is used with an Azure Logical SQL Instance. 

For medium sized implementations (300 worker pipelines across 3 execution stages) of the processing framework it is recommended to start with an __S2__ [service tier](/procfwk/servicetiers) or equivilant to provide enough compute for all metadata calls made from the [orchestrator](/procfwk/orchestrators) are served in a timely manor and without effecting platform runtime performance. Database storage will greatly depend on the amount of metadata you have and how long you wish to store data in the execution log [tables](/procfwk/tables).

The metadata database can be viewed as a whole in the below database diagrams. These are separated into two main groups.

___

## Metadata & Configuration Tables

[ ![](/procfwk/dbpart1.png) ](/procfwk/dbpart1.png){:target="_blank"}

___

## Runtime Execution & Logging Tables

![Database Diagram Part 2](/procfwk/dbpart2.png)

___