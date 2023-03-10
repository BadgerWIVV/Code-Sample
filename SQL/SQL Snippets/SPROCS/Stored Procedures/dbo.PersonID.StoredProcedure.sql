USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[PersonID]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PersonID]

AS

/**********************************************************************************/
/* DECLARE INITIAL PARAMETERS FOR THE TRANSACTION LOG */

DECLARE 
 @TransactionName			VARCHAR(1000) = ( '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME( @@PROCID ) + '].[' + OBJECT_NAME( @@PROCID ) + ']')
,@TransactionDescription	VARCHAR(1000) = 'Update the Person ID Tables';

/*************************************************************************************************************************/
/*AUTHOR: JARED MARX*/
/*CREATION DATE: 2016-02-18*/

/*VERSION HISTORY*/
/*
2016-02-19
V1: 1) INITIAL TABLE MEANT TO PUT A UNIQUE IDENTIFIER ON MEMBERS BASED ON FIRST NAME, LAST NAME, AND DOB.
2016-06-21
V2: 1) MODIFIED THE CODE TO PUT UNIQUE IDENTIFIERS ON MEMBERS WITHOUT A FIRST NAME, LAST NAME, AND A DOB = '0001-01-01'
	2) CHANGED THE WAY TO CREATE THE INITIAL PERSON ID TABLE TO ENSURE DATA STRUCTURES.
2017-01-17
V3:	1) BUG FIX: CORRECTED THE UPDATING OF THE TABLES TO WORK AS INTENDED
	2) ADDED A BEGIN-END AROUND THE INITIAL CREATE TABLE AND INSERT
*/

/*************************************************************************************************************************/
/*CREATE AN INITIAL PERSON ID CROSSWALK TABLE */

/*************************************************************************************************************************/
/*FIND ALL PAT_KEY ROWS*/

IF OBJECT_ID('tempdb..#PersonTable') IS NOT NULL DROP TABLE #PersonTable;

SELECT DISTINCT
 PAT_KEY
,[FSTNM] AS 'First Name'
,[LSTNM] AS 'Last Name'
,DOB
,MEMBER_HCC_ID
INTO 
#PersonTable
FROM 
wea_dw.DMLIB.MBR_DIM;

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #PersonTable
/*************************************************************************************************************************/
/*Add a PersonID to the PAT_KEYs*/

IF OBJECT_ID('tempdb..#PersonTableCleanNames') IS NOT NULL DROP TABLE #PersonTableCleanNames;

SELECT DISTINCT
 PAT_KEY
,MEMBER_HCC_ID
,[First Name]
,[Last Name]
,DOB
,DENSE_RANK() OVER ( ORDER BY [First Name], [Last Name], [DOB] ) AS 'PersonID' 
INTO 
#PersonTableCleanNames
FROM 
#PersonTable
WHERE
[First Name] != ''
AND
[Last Name] != ''
AND
DOB != '0001-01-01';

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #PersonTableCleanNames ORDER BY PersonID
/*************************************************************************************************************************/
/*SELECT THE MAX PERSONID TO CONTINUE THE COUNT FOR MEMBERS WITHOUT NAMES AND DOB*/

DECLARE @MaxInitialPersonId INT;

SET @MaxInitialPersonId = 
(
SELECT DISTINCT
MAX( [PersonID] ) AS 'Max Initial Person ID'
FROM 
#PersonTableCleanNames
);

/*FOR DEBUGGING*/ --SELECT * FROM #MaxInitialPersonId
/*************************************************************************************************************************/
/*Add a PersonID to the PAT_KEYs WITHOUT NAMES OR DOB*/

IF OBJECT_ID('tempdb..#PersonTableCleanNoNames') IS NOT NULL DROP TABLE #PersonTableCleanNoNames;

SELECT DISTINCT
 PAT_KEY
,MEMBER_HCC_ID
,[First Name]
,[Last Name]
,DOB
,DENSE_RANK() OVER ( ORDER BY [PAT_KEY] ) + @MaxInitialPersonId AS 'PersonID' 
INTO 
#PersonTableCleanNoNames
FROM 
#PersonTable
WHERE
[First Name] = ''
AND
[Last Name] = ''
AND
DOB = '0001-01-01';

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #PersonTableCleanNoNames ORDER BY PersonID
/*************************************************************************************************************************/
/*UNION THE PERSON IDS FOR MEMBERS WITH AND WITHOUT NAMES*/

IF OBJECT_ID('tempdb..#PersonTableClean') IS NOT NULL DROP TABLE #PersonTableClean;

SELECT DISTINCT
 PAT_KEY
,MEMBER_HCC_ID
,[First Name]
,[Last Name]
,DOB
,[PersonID]
INTO 
#PersonTableClean
FROM 
#PersonTableCleanNoNames

UNION ALL

SELECT DISTINCT
 PAT_KEY
,MEMBER_HCC_ID
,[First Name]
,[Last Name]
,DOB
,[PersonID]
FROM 
#PersonTableCleanNames

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #PersonTableCleanNoNames ORDER BY PersonID
/*************************************************************************************************************************/
/*INITIAL PERSON ID CROSSWALK.*/

/* DROP TABLE Dept_Actuary_JMarx.dbo.[Person_ID] */

IF OBJECT_ID('Dept_Actuary_JMarx.dbo.[Person_ID]') IS NULL

	BEGIN

		CREATE TABLE Dept_Actuary_JMarx.dbo.[Person_ID]
		(
		 PAT_KEY								INT
		,MEMBER_HCC_ID							VARCHAR( 50 )
		,PersonID								INT
		,[First Name]							VARCHAR( 15 )
		,[Last Name]							VARCHAR ( 20 )
		,DOB									DATE
		,[Count of Pat_Keys for a PersonID]		INT
		,[MAX PAT_KEY]							INT
		,[MAX MEMBER_HCC_ID]					VARCHAR( 50 )
		);

		INSERT INTO Dept_Actuary_JMarx.dbo.[Person_ID] 
		SELECT
		 MEM.PAT_KEY
		,MEM.MEMBER_HCC_ID
		,MEM.PersonID
		,MEM.[First Name]
		,MEM.[Last Name]
		,MEM.DOB
		,NULL AS 'Count of Pat_Keys for a PersonID'
		,NULL AS 'MAX PAT_KEY'
		,NULL AS 'MAX MEMBER_HCC_ID'
		FROM
		#PersonTableClean AS MEM;

	END;

/*************************************************************************************************************************/
/*DEVELOP LOGIC TO REUSE THE EXISTING PERSON_IDs*/

IF OBJECT_ID('tempdb..#PersonTableNew') IS NOT NULL DROP TABLE #PersonTableNew;

SELECT DISTINCT
 Person.PAT_KEY
,Person.[First Name]
,Person.[Last Name]
,Person.DOB
,Person.MEMBER_HCC_ID
,ID.PersonID
INTO 
#PersonTableNew
FROM 
#PersonTable AS Person

	LEFT JOIN DEPT_Actuary_JMarx.dbo.Person_ID AS ID
		ON ID.PAT_KEY = Person.PAT_KEY

WHERE
ID.PersonID IS NULL

/*FOR DEBUGGING*/ --SELECT TOP 100 * FROM  #PersonTableNew
/*FOR DEBUGGING*/ --SELECT COUNT(*) FROM  #PersonTableNew

/*************************************************************************************************************************/
/* CREATE A CROSSWALK TABLE FOR FIRST, LAST, DOB AND PERSON ID */

IF OBJECT_ID('tempdb..#PersonXWalk') IS NOT NULL DROP TABLE #PersonXWalk;

SELECT DISTINCT
 [First Name]
,[Last Name]
,[DOB]
,[PersonID]
INTO
#PersonXWalk
FROM
DEPT_Actuary_JMarx.dbo.Person_ID
WHERE
[First Name] != ''
AND
[Last Name] != ''
AND
[DOB] != '0001-01-01'

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM  #PersonXWalk
/*FOR DEBUGGING*/ --SELECT COUNT(*) FROM  #PersonXWalk

/*************************************************************************************************************************/
/* IDENTIFY NEW PAT_KEYS PERSON_ID BY FIRST NAME, LAST NAME, DOB */

IF OBJECT_ID('tempdb..#PersonTableNewMatch') IS NOT NULL DROP TABLE #PersonTableNewMatch;

SELECT DISTINCT
 Person.PAT_KEY
,Person.MEMBER_HCC_ID
,ID.PersonID
,Person.[First Name]
,Person.[Last Name]
,Person.DOB
INTO 
#PersonTableNewMatch
FROM 
#PersonTableNew AS Person

	LEFT JOIN #PersonXWalk AS ID
		 ON ID.[First Name] = Person.[First Name]
		 AND ID.[Last Name] = Person.[Last Name]
		 AND ID.DOB = Person.DOB;

/*FOR DEBUGGING*/ --SELECT TOP 100 * FROM  #PersonTableNewMatch
/*FOR DEBUGGING*/ --SELECT CASE WHEN PersonID IS NULL THEN NULL ELSE 'Present' END AS 'PersonID Indicator' ,COUNT(*) FROM  #PersonTableNewMatch GROUP BY CASE WHEN PersonID IS NULL THEN NULL ELSE 'Present' END
/*FOR DEBUGGING*/ --SELECT COUNT(*) FROM  #PersonTableNewMatch

/*************************************************************************************************************************/
/*UPDATE PERSONID TABLE WITH NEWLY IDENTIFIED ROWS*/

INSERT INTO DEPT_Actuary_JMarx.dbo.Person_ID

SELECT
 PAT_KEY
,MEMBER_HCC_ID
,PersonID
,[First Name]
,[Last Name]
,DOB
,NULL AS 'Count of Pat_Keys for a PersonID'
,NULL AS 'MAX PAT_KEY'
,NULL AS 'MAX MEMBER_HCC_ID'
FROM 
#PersonTableNewMatch
WHERE
PersonID IS NOT NULL;

/*************************************************************************************************************************/
/*IDENTIFY THE MAX PERSONID*/

DECLARE 
@MaxPersonID AS INT = ( SELECT MAX ( [PersonID] ) FROM DEPT_Actuary_JMarx.dbo.Person_ID );

/*FOR DEBUGGING*/  --SELECT @MaxPersonID

/*************************************************************************************************************************/
/*ADD A PERSON ID TO THOSE NEW PAT KEYS WHO HAVE A NAME AND DOB*/

IF OBJECT_ID('tempdb..#PersonTableNewNoMatch') IS NOT NULL DROP TABLE #PersonTableNewNoMatch;

SELECT
 PAT_KEY
,MEMBER_HCC_ID
,DENSE_RANK() OVER ( ORDER BY [First Name], [Last Name], [DOB] ) + @MaxPersonID AS 'PersonID' 
,[First Name]
,[Last Name]
,DOB
INTO 
#PersonTableNewNoMatch
FROM 
#PersonTableNewMatch
WHERE
PersonID IS NULL
AND
[First Name] != ''
AND
[Last Name] != ''
AND
DOB != '0001-01-01';

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #PersonTableNewNoMatch
/*FOR DEBUGGING*/ --SELECT COUNT(*) FROM #PersonTableNewNoMatch

/*************************************************************************************************************************/
/*UPDATE PERSONID TABLE WITH NEWLY CREATED ROWS*/

INSERT INTO DEPT_Actuary_JMarx.dbo.Person_ID

SELECT
 PAT_KEY
,MEMBER_HCC_ID
,PersonID
,[First Name]
,[Last Name]
,DOB
,NULL AS 'Count of Pat_Keys for a PersonID'
,NULL AS 'MAX PAT_KEY'
,NULL AS 'MAX MEMBER_HCC_ID'
FROM 
#PersonTableNewNoMatch;

/*************************************************************************************************************************/
/*IDENTIFY THE NEWEST MAX PERSONID*/

DECLARE @MaxPersonIDAfterNames AS INT = ( SELECT MAX ( [PersonID] ) FROM DEPT_Actuary_JMarx.dbo.Person_ID );

/*FOR DEBUGGING*/  --SELECT @MaxPersonIDAfterNames

/*************************************************************************************************************************/
/*ADD A PERSON ID TO THOSE NEW PAT KEYS WHO HAVE A NAME AND DOB*/

IF OBJECT_ID('tempdb..#PersonTableNewNoMatchNoNames') IS NOT NULL DROP TABLE #PersonTableNewNoMatchNoNames;

SELECT
 PAT_KEY
,MEMBER_HCC_ID
,DENSE_RANK() OVER ( ORDER BY [PAT_KEY] ) + @MaxPersonIDAfterNames AS 'PersonID' 
,[First Name]
,[Last Name]
,DOB
INTO 
#PersonTableNewNoMatchNoNames
FROM 
#PersonTableNewMatch
WHERE
PersonID IS NULL
AND
[First Name] = ''
AND
[Last Name] = ''
AND
DOB = '0001-01-01';

/*FOR DEBUGGING*/ --SELECT * FROM #PersonTableNewNoMatchNoNames
/*************************************************************************************************************************/
/*UPDATE PERSONID TABLE WITH NEWLY CREATED ROWS*/

INSERT INTO DEPT_Actuary_JMarx.dbo.Person_ID

SELECT
 PAT_KEY
,MEMBER_HCC_ID
,PersonID
,[First Name]
,[Last Name]
,DOB
,NULL AS 'Count of Pat_Keys for a PersonID'
,NULL AS 'MAX PAT_KEY'
,NULL AS 'MAX MEMBER_HCC_ID'
FROM 
#PersonTableNewNoMatchNoNames;

/*************************************************************************************************************************/
/*FIND MAX PAT_KEY, MEMBER_HCC_ID, AND PAT_KEY COUNT FOR EACH PERSONID*/

IF OBJECT_ID('tempdb..#PersonGroupedInfo') IS NOT NULL DROP TABLE #PersonGroupedInfo;

SELECT 
 PersonID
,COUNT( DISTINCT PAT_KEY )  AS 'Count of Pat_Keys for a PersonID'
,MAX( PAT_KEY )  AS 'MAX PAT_KEY' 
,MAX( MEMBER_HCC_ID )  AS 'MAX MEMBER_HCC_ID' 
INTO 
#PersonGroupedInfo
FROM 
DEPT_Actuary_JMarx.dbo.Person_ID
GROUP BY 
PersonID

/*************************************************************************************************************************/
/*UPDATE PERSONID TABLE WITH MAX PAT_KEY, MEMBER_HCC_ID, and the number of rows PAT_KEYs associated to a PersonID*/

UPDATE DEPT_Actuary_JMarx.dbo.Person_ID 

SET 
 DEPT_Actuary_JMarx.dbo.Person_ID.[Count of Pat_Keys for a PersonID] = New.[Count of Pat_Keys for a PersonID]
,DEPT_Actuary_JMarx.dbo.Person_ID.[Max PAT_KEY] = New.[Max PAT_KEY]
,DEPT_Actuary_JMarx.dbo.Person_ID.[MAX MEMBER_HCC_ID] = CAST( New.[MAX MEMBER_HCC_ID] AS VARCHAR( 50 ) )
FROM 
DEPT_Actuary_JMarx.dbo.Person_ID

	JOIN #PersonGroupedInfo AS New
		ON New.PersonID = DEPT_Actuary_JMarx.dbo.Person_ID.PersonID;


/*************************************************************************************************************************/
/*ADD A ROW TO THE TRANSACTION LOG*/

EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Executed'
	,@TransactionComment = 'The procedure to update the PersonID table was executed. Success/Failure/Error state unknown.'
	,@TransactionName =  @TransactionName
GO
