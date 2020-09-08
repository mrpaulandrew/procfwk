CREATE PROCEDURE procfwk_GetPropertyValueInternal.[test WHEN property name does not exist THEN empty string returned]
AS

-- ARRANGE
DECLARE @propertyName NVARCHAR(128) = 'TestProperty'

EXEC tSQLt.FakeTable 'procfwk.CurrentProperties'

DECLARE @expected NVARCHAR(4000) = ''

-- ACT
DECLARE @actual NVARCHAR(4000) = procfwk.GetPropertyValueInternal(@propertyName)

-- ASSERT
EXEC tSQLt.AssertEquals 
  @Expected = @expected
, @Actual = @actual
