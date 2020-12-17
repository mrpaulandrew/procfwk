# Synonyms

___
[<< Contents](/procfwk/contents) / [Database](/procfwk/database)

___

To support backwards compatibility when database objects have changed [schema's](/procfwk/schemas) or been renamed in the [database](/procfwk/database) a set of pass through Synonyms exist. They provide a simple redirect from an old object schema/name to its current schema/name.

Any database objects developed as part of the framework code project do not use synonyms and have had code replaced to call the current object names directly.

__Example:__
```sql
CREATE SYNONYM [procfwk].[DataFactoryDetails] 
FOR [procfwk].[DataFactorys]
```
___

In a later release of the processing framework when database object names have matured all Synonyms will be deprecated.

___