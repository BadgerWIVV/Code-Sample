DECLARE
 @BaseTable			VARCHAR(255)		= 'DatabaseName.dbo.TableName1'
,@TargetTable		VARCHAR(255)		= 'DatabaseName.dbo.TableName2'
,@Query				VARCHAR(MAX);

SET @Query = CONCAT(

'

WITH #EDW AS (

SELECT
 [Target Count] =
	COUNT(*)
FROM
', @TargetTable, '
),

#PROD AS (

SELECT
 [Base Count] =
	COUNT(*)
FROM
', @BaseTable, '

)

SELECT
 Prod.[Base Count]
,EDW.[Target Count]
,[Difference] =
	Prod.[Base Count] - EDW.[Target Count]
FROM
#PROD AS Prod
	CROSS JOIN #EDW AS EDW
' )

EXEC( @Query )