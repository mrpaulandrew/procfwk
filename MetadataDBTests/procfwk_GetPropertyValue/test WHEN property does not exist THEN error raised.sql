CREATE PROCEDURE procfwk_GetPropertyValue.[test WHEN property does not exist THEN error raised]
AS

-- ARRANGE
DECLARE @propertyName NVARCHAR(128) = 'OtherProperty'

EXEC tSQLt.FakeTable 'procfwk.Properties'

INSERT INTO procfwk.Properties (
  [PropertyName]
, [PropertyValue]
) VALUES (
  'TestProperty'
, 'TestPropertyValue'
)

-- EXPECT
EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%Invalid property name %'

-- ACT
CREATE TABLE #actual (
  PropertyValue NVARCHAR(4000)
)

INSERT INTO #actual (
  PropertyValue 
)
EXEC procfwk.GetPropertyValue @propertyName
