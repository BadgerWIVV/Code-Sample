USE wea_prod_dw;
GO

DECLARE @TableName varchar (100) = '%TABLE_NAME%';

SELECT 
 'Table' AS 'FILE TYPE'
,SCHEMA_NAME(schema_id) AS 'Schema Name'
,t.name AS 'Table Name'
,c.name AS 'Column Name'
FROM sys.tables AS t
JOIN sys.columns c 
	ON t.OBJECT_ID = c.OBJECT_ID
WHERE 
c.name LIKE @TableName

UNION ALL

SELECT 
 'View' AS 'FILE TYPE'
,SCHEMA_NAME(schema_id) AS 'Schema Name'
,t.name AS 'Table Name'
,c.name AS 'Column Name'
FROM sys.views AS t
JOIN sys.columns c 
	ON t.OBJECT_ID = c.OBJECT_ID
WHERE 
c.name LIKE @TableName
ORDER BY 
 [File Type]
,[Schema Name]
,[Table Name]