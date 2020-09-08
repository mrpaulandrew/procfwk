CREATE PROCEDURE procfwk_GetPropertyValue.[test WHEN property invalidated THEN error raised]
AS

-- ARRANGE
DECLARE @propertyName NVARCHAR(128) = 'TestProperty'

EXEC tSQLt.FakeTable 'procfwk.Properties'

INSERT INTO procfwk.Properties (
  [PropertyName]
, [PropertyValue]
, ValidTo
) VALUES (
  'TestProperty'
, 'TestPropertyValue'
, GETDATE()
)

-- EXPECT
EXEC tSQLt.ExpectException @ExpectedMessagePattern = '% does not have a current valid version %'

-- ACT
CREATE TABLE #actual (
  PropertyValue NVARCHAR(4000)
)

INSERT INTO #actual (
  PropertyValue 
)
EXEC procfwk.GetPropertyValue @propertyName
