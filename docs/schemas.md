# Schemas

___
[<< Contents](/procfwk/contents) / [Database](/procfwk/database)

___

The metadata [database](/procfwk/database) contains four custom schema's. These are used and defined as follows:

* __procfwk__ - the core schema housing all objects used by the [orchestrator](/procfwk/orchestrators) during an execution of the framework.
* __procfwkHelpers__ - this schema house database objects used for development and to help users of the framework edit metadata. Nothing from this schema is used at runtime.
* __procfwkTesting__ - used to support the NUnit [testing](/procfwk/testing) project included as part of the processing framework solution. Objects in this schema wrap up other database calls to make testing easier.
* __procfwkReporting__ - this schema mainly houses database views that are consumed by Power BI for the purpose of creating operational dashboards on top of the framework execution logs.

___

For completeness:

* __dbo__ - the database default dbo schema is used for generic objects or objects that may otherwise need a separate security configuration. For example, the service principals [table](/procfwk/tables).

___