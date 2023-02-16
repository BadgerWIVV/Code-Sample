USE HCI;
GO

DECLARE
 @table_name			NVARCHAR(255)	=	'PHYSICIAN_FEE_SCHEDULE_2021'
,@schema_name			NVARCHAR(255)	=	'REPORT'
,@unpivot_columns		NVARCHAR(MAX)	=	''
,@SQL					NVARCHAR(MAX)	=	'';

SELECT
@SQL =
	STUFF(
			(
				SELECT ', COUNT( DISTINCT ' + QUOTENAME(C.COLUMN_NAME) + ') [' + C.COLUMN_NAME + ']'
				FROM
					INFORMATION_SCHEMA.COLUMNS AS C
				WHERE
					TABLE_NAME = @table_name AND TABLE_SCHEMA = @schema_name
				ORDER BY
					C.ORDINAL_POSITION
				FOR XML PATH(''), TYPE
			).value('.', 'nvarchar(max)'), 1, 2, ''
		);

--PRINT @SQL;


SELECT
@unpivot_columns =
		STUFF(
			(
				SELECT ','+ QUOTENAME( [column_name] )
				FROM
					information_schema.columns
				WHERE
				TABLE_NAME = @table_name
				AND
				TABLE_SCHEMA = @schema_name
				FOR XML PATH('')), 1, 1, ''
			)

--SELECT @unpivot_columns

--IF OBJECT_ID( 'TEMPDB.DBO.##PivotedColumns' ) IS NOT NULL DROP TABLE ##PivotedColumns;
--GO

SET
@SQL =
'IF OBJECT_ID(''[TEMPDB].[dbo].#PivotedColumns'') IS NOT NULL DROP TABLE #PivotedColumns'
+
' 

SELECT ' + @SQL + '
INTO
#PivotedColumns
FROM
[' + @schema_name + '].[' + @table_name + '];'
+
'

--SELECT * FROM #PivotedColumns
'	
+
'
WITH Base AS (
SELECT
 [Column Name]
,[Distinct Count]
FROM 
#PivotedColumns
UNPIVOT
(
	[Distinct Count]
	FOR [Column Name] IN (' + @unpivot_columns + ')
) AS Unpivoted

),

TotalRows AS (
SELECT
[Total Row Count] =
	COUNT(*)
FROM
[' + @schema_name + '].[' + @table_name + ']

)

SELECT
*
FROM
Base

	CROSS JOIN TotalRows
'
;

PRINT
@SQL;

EXECUTE
SP_EXECUTESQL @SQL;
GO
