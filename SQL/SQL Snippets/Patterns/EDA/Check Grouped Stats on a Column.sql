DECLARE
 @ColumnName			VARCHAR(500) = 'ColumnNameHere'
,@TableName				VARCHAR(500) = 'TableName'
,@TableName2			VARCHAR(500) = 'TableName2'
,@Query					VARCHAR(MAX);


SET @Query = CONCAT('SELECT TOP 0 [Grouped Stats for: ', @ColumnName, ' in table: ', @TableName ,'] = NULL' );
EXEC( @Query);

SET @Query = CONCAT('
SELECT
 [Min] = MIN( LEN (',@ColumnName,' ) )
,[Max] = MAX( LEN ( ',@ColumnName,') )
,[Max LTrim] = MAX( LEN (LTRIM(',@ColumnName,') ) )
,[Max LTrim Rtrim] = MAX( LEN (RTRIM(LTRIM( ',@ColumnName,') ) ) )
FROM ',@TableName );

EXEC( @Query);


SET @Query = CONCAT('SELECT TOP 0 [Grouped Stats for: ', @ColumnName, ' in table: ', @TableName2 ,'] = NULL' );
EXEC( @Query);

SET @Query = CONCAT('
SELECT
 [Min] = MIN( LEN (',@ColumnName,' ) )
,[Max] = MAX( LEN ( ',@ColumnName,') )
,[Max LTrim] = MAX( LEN (LTRIM(',@ColumnName,') ) )
,[Max LTrim Rtrim] = MAX( LEN (RTRIM(LTRIM( ',@ColumnName,') ) ) )
FROM ',@TableName2 );

EXEC( @Query) 

