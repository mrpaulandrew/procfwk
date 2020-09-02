CREATE SCHEMA procfwk_GetPropertyValueInternal
    AUTHORIZATION [dbo];
GO

EXEC sp_addextendedproperty @name = N'tSQLt.TestClass', @value = 1, @level0type = N'SCHEMA', @level0name = N'procfwk_GetPropertyValueInternal'
