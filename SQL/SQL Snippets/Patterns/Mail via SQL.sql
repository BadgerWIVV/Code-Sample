--==========================================================
-- Test Database Mail
--==========================================================

/* ADDITIONAL OPTIONS CAN BE FOUND HERE:
https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-send-dbmail-transact-sql

*/


/*
NOTE: 

FILE ATTACHMENT FROM @FILE_BEING_SENT WAS NOT WORKING FOR ME.  WILL NEED DEBUGGING, HENCE COMMENTED OUT.

*/

DECLARE 
 @sub					VARCHAR(100)
,@body_text				NVARCHAR(MAX)
,@from_address			VARCHAR(100)		=	'email@domain.com'
,@query_being_sent		VARCHAR(MAX)
,@file_being_sent		NVARCHAR(MAX)
,@query_being_sent_name	VARCHAR(MAX)		=	'TEST QUERY ATTACHMENT.csv'
,@HTMLbody				VARCHAR(MAX);


SELECT @sub = 'Test from New SQL install on ' + @@servername;

SELECT @body_text = N'This is a test of Database Mail.' + CHAR(13) + CHAR(13) + 'SQL Server Version Info: ' + CAST(@@version AS VARCHAR(500));


set @HTMLbody = cast( (

select td = dbtable + '</td><td>' + cast( entities as varchar(30) ) + '</td><td>' + cast( rows as varchar(30) )
from (
      select dbtable  = object_name( object_id ),
             entities = count( distinct name ),
             rows     = count( * )
      from sys.columns
      group by object_name( object_id )
      ) as d


for xml path( 'tr' ), type ) as varchar(max) )

set @HTMLbody = '<table cellpadding="2" cellspacing="2" border="1">'
          + '<tr><th>Database Table</th><th>Entity Count</th><th>Total Rows</th></tr>'
          + replace( replace( @HTMLbody, '&lt;', '<' ), '&gt;', '>' )
          + '</table>'


--SELECT @file_being_sent = N'FullFilePathAndDocumentName'

/* THE PRINT ''SEP=;'' ALLOWS FOR EXCEL TO KNOW THE PROPER SEPARATION AND READ THE .CSV PROPERLY */
SELECT @query_being_sent = '
print ''sep=;''

SELECT TOP 1 * From Table'

EXEC msdb.dbo.[sp_send_dbmail] 
 @recipients = 'email@domain.com'
,@subject = @sub
--,@body = @body_text
,@body = @HTMLbody
,@body_format = 'HTML'
,@from_address = @from_address
,@query = @query_being_sent
,@attach_query_result_as_file = 1
,@query_attachment_filename = @query_being_sent_name
,@query_result_header = 1
,@query_result_width = 32767
,@query_result_separator = ';'
--,@file_attachments = @file_being_sent;
