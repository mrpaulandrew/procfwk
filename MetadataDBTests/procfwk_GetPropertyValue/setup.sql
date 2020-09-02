CREATE PROCEDURE procfwk_GetPropertyValue.[setup]
AS

DECLARE @propertyName NVARCHAR(128) = 'TestProperty'

EXEC tSQLt.FakeTable 'procfwk.CurrentProperties'

INSERT INTO procfwk.CurrentProperties (
  [PropertyName]
, [PropertyValue]
) VALUES (
  @propertyName
, 'TestPropertyValue'
)
