USE Database;
GO

IF OBJECT_ID( 'Database.dbo.test' ) IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.test
	END;
GO

CREATE PROCEDURE dbo.test
AS 
BEGIN

    SELECT [name] FROM sys.databases

    RETURN ( SELECT COUNT(*) FROM sys.databases )
END;

/* OPTION 1: RETURN RESULT SETS FROM SP */
/* Returns table from SP execution */
EXEC test;



/* OPTION 2: RETURN RESULT SETS FROM SP AND STORE RETURN VALUE AS A PARAMETER */
--Use this to test
DECLARE @returnval int

/* Returns the table & stores RETURN value to parameter */
EXEC @returnval = test 

/* Selects the return parameter */
SELECT @returnval



/* OPTION 3: SAVE THE RESULT SET FROM THE SP INTO A TABLE TO USE LATER */

IF OBJECT_ID( 'TEMPDB.DBO.#TestTable' ) IS NOT NULL
	BEGIN
		DROP TABLE #TestTable
	END;

CREATE TABLE #TestTable  (
[Name]	VARCHAR(MAX)
);

INSERT INTO #TestTable
EXEC test

SELECT TOP 5 * FROM #TestTable
