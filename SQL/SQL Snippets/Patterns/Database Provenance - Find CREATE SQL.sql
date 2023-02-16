USE DatabaseName;
GO

DECLARE
 @ObjectName			VARCHAR(50) = '%Stored_Procedure_Name_Here%';


SELECT
 [Schema Name] =
	ObjectSchema.name
,Objects.name
,Objects.type_desc
,Objects.create_date
,Objects.modify_date
,Modules.[definition]
FROM
[sys].[objects] AS Objects
	
	LEFT JOIN sys.schemas AS ObjectSchema
		ON ObjectSchema.schema_id = Objects.schema_id

	LEFT JOIN sys.sql_modules AS Modules
		ON Objects.object_id = Modules.object_id

WHERE
Objects.type_desc NOT IN ( 'SQL_SCALAR_FUNCTION' )
AND
Objects.name LIKE @ObjectName
--AND
--Modules.definition IS  NOT NULL