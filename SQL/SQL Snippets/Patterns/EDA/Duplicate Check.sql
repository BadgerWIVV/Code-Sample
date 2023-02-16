IF OBJECT_ID ( 'TEMPDB..##Duplicates1234' ) IS NOT NULL DROP TABLE ##Duplicates1234;

DECLARE
 @FieldName			VARCHAR(255)		= 'Column_Name'
,@TableName			VARCHAR(255)		= 'DatabaseName.dbo.TableName'
,@Query				VARCHAR(MAX);

SET @Query = 

CONCAT(
'
SELECT
', @FieldName, '
,[Row Count] =
	COUNT(*)
INTO
##Duplicates1234
FROM
', @TableName, '
GROUP BY
',@FieldName, '
HAVING
COUNT(*) > 1

SELECT
*
FROM
', @TableName,' AS Base
	
	JOIN ##Duplicates1234 AS Duplicates
		ON Duplicates.',@FieldName, ' = Base.',@FieldName, '
ORDER BY
 Duplicates.[Row Count] DESC
,Base.',@FieldName )

EXEC ( @Query) 