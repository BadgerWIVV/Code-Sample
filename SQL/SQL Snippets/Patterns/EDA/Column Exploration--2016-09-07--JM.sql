DECLARE
 @table VARCHAR(200) = 'DatabaseName.dbo.TableName'
,@field VARCHAR(100) = '[Column_Name]';


DECLARE @sqlCommand VARCHAR (2000 );

SET @sqlCommand =
CONCAT(
'SELECT
',@field,'

,COUNT(*) AS ''Line Count''
FROM '
,@table,'
--WHERE
--ISNUMERIC( ',@field,' ) = 0
--LEN(',@field,' ) < 5
--ISNUMERIC( SUBSTRING(', @field,', 2, LEN(',@field,' ) ) ) = 0

GROUP BY
',@field,'

ORDER BY
--',@field,'
COUNT(*) DESC

--SELECT
-- SUM( ISNUMERIC( ',@field,' ) ) AS ''Number of Numeric Fields''
--,SUM( ISDATE( ',@field,' ) ) AS ''Number of Date Fields''
--,COUNT(*) AS ''Total Line Count''
--FROM
--',@table,''
)

EXEC( @sqlCommand );
