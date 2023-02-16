USE Database;
GO

IF OBJECT_ID( 'Database.dbo.test' ) IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.test
	END;
GO

CREATE FUNCTION dbo.test()
RETURNS @ReturnTable TABLE 
(
 Column1	INT
,Column2	VARCHAR(255)
)
AS 
BEGIN

	INSERT INTO @ReturnTable
    SELECT database_id, name FROM sys.databases

	RETURN
END
GO
/* OPTION 1: RETURN RESULT SETS FROM SP */
/* Returns table from SP execution */

SELECT
*
FROM
dbo.test();
