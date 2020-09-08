CREATE PROCEDURE procfwk_GetPropertyValueInternal.[test WHEN property exists THEN property value returned]
AS

-- ARRANGE
DECLARE @propertyName NVARCHAR(128) = 'TestProperty'

EXEC tSQLt.FakeTable 'procfwk.CurrentProperties'

INSERT INTO procfwk.CurrentProperties (
  [PropertyName]
, [PropertyValue]
) VALUES (
  'TestProperty'
, 'TestPropertyValue'
)

DECLARE @expected NVARCHAR(4000) = 'TestPropertyValue'

-- ACT
DECLARE @actual NVARCHAR(4000) = procfwk.GetPropertyValueInternal(@propertyName)

-- ASSERT
EXEC tSQLt.AssertEquals 
  @Expected = @expected
, @Actual = @actual
