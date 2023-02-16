USE ServerNameHere;
GO

DECLARE
 @TableName				VARCHAR(500) = 'Server.Database.Schema.TableName'
,@ShortTableName		VARCHAR(500) = 'TableName'
,@TableName2			VARCHAR(500) = 'Server2.Database2.Schema2.TableName'
,@Query					VARCHAR(MAX)
,@Query2				VARCHAR(MAX) = '';


SET @Query = CONCAT('SELECT TOP 0 [Grouped Stats for table: ', @TableName ,'] = NULL;', CHAR(10), CHAR(13)  );
EXEC( @Query);

SELECT @Query = CONCAT( @Query, '
SELECT
 [Column Name] = ''',C.COLUMN_NAME,'''
,[Min] = MIN( LEN (',C.COLUMN_NAME,' ) )
,[Max] = MAX( LEN ( ',C.COLUMN_NAME,') )
,[Max LTrim] = MAX( LEN (LTRIM(',C.COLUMN_NAME,') ) )
,[Max LTrim Rtrim] = MAX( LEN (RTRIM(LTRIM( ',C.COLUMN_NAME,') ) ) )
FROM ',@TableName, ';' , CHAR(10) , CHAR(13) )
	FROM
		INFORMATION_SCHEMA.COLUMNS C
	WHERE
		C.TABLE_NAME = @ShortTableName

--PRINT @Query
EXEC( @Query);




SET @Query = CONCAT('SELECT TOP 0 [Distribution Stats for table: ', @TableName ,'] = NULL;', CHAR(10), CHAR(13)  );
EXEC( @Query);

	SELECT @Query2 = @Query2 + 'SELECT ' + C.COLUMN_NAME + ' ,[Row Count] = COUNT(*) FROM ' + @TableName  + ' GROUP BY ' + C.COLUMN_NAME + ' ORDER BY COUNT(*) DESC;' + CHAR(10) + CHAR(13)
	FROM
		INFORMATION_SCHEMA.COLUMNS C
	WHERE
		C.TABLE_NAME = @ShortTableName

--PRINT @Query2
EXEC( @Query2);









SET @Query = CONCAT('SELECT TOP 0 [Grouped Stats for table: ', @TableName2 ,'] = NULL;', CHAR(10), CHAR(13)  );
EXEC( @Query);

SELECT @Query = CONCAT( @Query, '
SELECT
 [Column Name] = ''',C.COLUMN_NAME,'''
,[Min] = MIN( LEN (',C.COLUMN_NAME,' ) )
,[Max] = MAX( LEN ( ',C.COLUMN_NAME,') )
,[Max LTrim] = MAX( LEN (LTRIM(',C.COLUMN_NAME,') ) )
,[Max LTrim Rtrim] = MAX( LEN (RTRIM(LTRIM( ',C.COLUMN_NAME,') ) ) )
FROM ',@TableName2, ';' , CHAR(10) , CHAR(13) )
	FROM
		INFORMATION_SCHEMA.COLUMNS C
	WHERE
		C.TABLE_NAME = @ShortTableName

--PRINT @Query
EXEC( @Query);


SET @Query = CONCAT('SELECT TOP 0 [Distribution Stats for table: ', @TableName2 ,'] = NULL;', CHAR(10), CHAR(13)  );
EXEC( @Query);

	SELECT @Query2 = @Query2 + 'SELECT ' + C.COLUMN_NAME + ' ,[Row Count] = COUNT(*) FROM ' + @TableName2  + ' GROUP BY ' + C.COLUMN_NAME + ' ORDER BY COUNT(*) DESC;' + CHAR(10) + CHAR(13)
	FROM
		INFORMATION_SCHEMA.COLUMNS C
	WHERE
		C.TABLE_NAME = @ShortTableName

--PRINT @Query2
EXEC( @Query2);
