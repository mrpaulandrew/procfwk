CREATE PROCEDURE procfwk_GetPropertyValue.[test WHEN property exists THEN property value returned]
AS

-- ARRANGE
DECLARE @propertyName NVARCHAR(128) = 'TestProperty'

EXEC tSQLt.FakeTable 'procfwk.Properties'

INSERT INTO procfwk.Properties (
  [PropertyName]
, [PropertyValue]
) VALUES (
  'TestProperty'
, 'TestPropertyValue'
)

SELECT N'TestPropertyValue' AS PropertyValue
INTO #expected

-- ACT
CREATE TABLE #actual (
  PropertyValue NVARCHAR(4000)
)

INSERT INTO #actual (
  PropertyValue 
)
EXEC procfwk.GetPropertyValue @propertyName

-- ASSERT
EXEC tSQLt.AssertEqualsTable
  @Expected = '#expected'
, @Actual = '#actual'
