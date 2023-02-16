SELECT TOP 1000
 [Date Time] =
	execquery.last_execution_time
,[Script] =
	execsql.text
--,execsql.*
FROM
sys.dm_exec_query_stats AS execquery

CROSS APPLY sys.dm_exec_sql_text(execquery.sql_handle) AS execsql

WHERE
1 = 1
AND
execsql.text LIKE '%WEA.DN.%'

ORDER BY
execquery.last_execution_time DESC
