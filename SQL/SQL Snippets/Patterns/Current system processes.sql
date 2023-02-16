/**************************************************************************************************************/

select
    P.spid
,   right(convert(varchar, 
            dateadd(ms, datediff(ms, P.last_batch, getdate()), '1900-01-01'), 
            121), 12) as 'batch_duration'
,   P.program_name
,   P.hostname
,   P.loginame
,p.cmd
from master.dbo.sysprocesses P
where P.spid > 50
and      P.status not in ('background', 'sleeping')
and      P.cmd not in ('AWAITING COMMAND'
                    ,'MIRROR HANDLER'
                    ,'LAZY WRITER'
                    ,'CHECKPOINT SLEEP'
                    ,'RA MANAGER')
order by batch_duration DESC;
GO
/**************************************************************************************************************/
 
--EXEC sp_who 

--EXEC sp_who2

EXEC sp_whoisactive

 /**************************************************************************************************************/
 /* Currently do not have permissions */

-- SELECT * 
--FROM 
--   sys.dm_exec_sessions s
--   LEFT  JOIN sys.dm_exec_connections c
--        ON  s.session_id = c.session_id
--   LEFT JOIN sys.dm_db_task_space_usage tsu
--        ON  tsu.session_id = s.session_id
--   LEFT JOIN sys.dm_os_tasks t
--        ON  t.session_id = tsu.session_id
--        AND t.request_id = tsu.request_id
--   LEFT JOIN sys.dm_exec_requests r
--        ON  r.session_id = tsu.session_id
--        AND r.request_id = tsu.request_id
--   OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) TSQL