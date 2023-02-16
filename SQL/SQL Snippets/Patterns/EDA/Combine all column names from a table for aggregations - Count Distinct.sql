USE HCI;
GO

DECLARE
	@Schema_name		NVARCHAR(50) = 'REPORT',
	@Table_name			NVARCHAR(100) = 'NDC_SAVINGS_REFERENCE'


	DECLARE @QUERY NVARCHAR(MAX) = ''

	SELECT @QUERY = @QUERY + 'COUNT( DISTINCT [' + C.COLUMN_NAME + '] ) AS [' + C.COLUMN_NAME + '],'
	FROM
		INFORMATION_SCHEMA.COLUMNS C
	WHERE
		C.TABLE_NAME = @Table_name


/* Remove trailing comma */
SET @QUERY = SUBSTRING( @QUERY, 1, LEN( @QUERY ) - 1 );

PRINT @QUERY;

SET @QUERY = ( 'SELECT ' + @QUERY + ' FROM [' + @Schema_name + '].[' + @Table_name + ']');

PRINT @QUERY;

EXEC (@QUERY);
