USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[PersonHistory_Opioids]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PersonHistory_Opioids]

AS

/**********************************************************************************/
/* DECLARE INITIAL PARAMETERS FOR THE TRANSACTION LOG */

DECLARE 
 @TransactionName			VARCHAR(1000) = ( '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME( @@PROCID ) + '].[' + OBJECT_NAME( @@PROCID ) + ']')
,@TransactionDescription	VARCHAR(1000) = 'Update the PersonHistory-Opioids Table'
,@MaxVersionYear			INT;

/*****************************************************************************************************************************/
/* AUTHOR: JARED MARX */
/* CREATION DATE: 2016-06-22*/
/*****************************************************************************************************************************/
/*
VERSIONS:
V1: 1) CREATE A PERSON-DATE TABLE FOR ALL OPIOID CPT/HCPCS CODES
V2: 1) UPDATE SCRIPT TO USE CDC_OPIOID TABLE AND ACQUIRE BASED ON MOST RECENT YEAR

*/
/*****************************************************************************************************************************/
/* 
PROCESS:
1) CREATE A LIST OF CPT/HCPCS CODES BASED ON CDC OPIOID LIST
2) FIND ALL DATES FOR A MEMBER THAT INVOLVES AN OPIOID
*/

/************************************************************************************************************/
/* SET THE PARAMETER FOR MAX CDC_OPIOID YEAR*/

SET @MaxVersionYear = (

SELECT 
MAX( [Version Year] )
FROM
[DEPT_Actuary_JMarx].[dbo].[CDC_OPIOIDS]

);

/************************************************************************************************************/
/*CREATE A X-WALK FOR NDC CODES*/

IF OBJECT_ID('tempdb..#NDC') IS NOT NULL DROP TABLE #NDC;

SELECT DISTINCT
 NDC.SVC_CD_KEY
INTO 
#NDC
FROM 
wea_dw.DMLIB.[NDC_PRDCT_CD_REF] AS NDC

	JOIN [DEPT_Actuary_JMarx].[dbo].[CDC_OPIOIDS] AS Opioid
		ON Opioid.NDC = LTRIM( RTRIM( NDC.PRDID ) )
		AND Opioid.[Version Year] = @MaxVersionYear

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #NDC

/************************************************************************************************************/
/*FIND ALL THE OPIOID PERSON-DATES*/

IF OBJECT_ID('tempdb..#AllClaimLines') IS NOT NULL DROP TABLE #AllClaimLines;

SELECT DISTINCT
 Person.PersonID
,CF.[PAT_KEY]
,C.DATEKEY AS 'Incurred Date'
INTO 
#AllClaimLines
FROM 
wea_dw.dmlib.clmln_fact AS CLF
	
	JOIN wea_dw.DMLIB.DATE_DIM AS C
		ON C.DATE_KEY = CLF.INCDT_KEY

	LEFT JOIN [wea_dw].[DMLIB].[CLM_FACT] AS CF
		ON CLF.CLAIMKEY = CF.CLAIMKEY

		LEFT JOIN DEPT_Actuary_JMarx.dbo.Person_ID AS Person
			ON Person.PAT_KEY = CF.PAT_KEY

	LEFT JOIN wea_dw.DMLIB.CLMLN_DIM AS ClDim
		ON CLDim.CLMLN_KEY = CLF.CLMLN_KEY

		LEFT JOIN [wea_dw].[DMLIB].[CLM_STS_REF] AS CSR 
			ON CSR.STATKEY = CLDim.STATKEY

		JOIN #NDC AS NDC
			ON NDC.SVC_CD_KEY = ClDim.SVC_CD_KEY

		--LEFT JOIN wea_dw.DMLIB.[NDC_PRDCT_CD_REF] AS NDC
		--	ON NDC.SVC_CD_KEY = ClDim.SVC_CD_KEY

		--	JOIN [DEPT_Actuary_JMarx].[dbo].[Opioids--2015-07-17--JM] AS Opioid
		--		ON Opioid.NDC = LTRIM( RTRIM( NDC.PRDID ) )
WHERE 
ClDim.[DUPLIC] = 'N'
AND
CSR.CLMSTS IN (' P' )/*PAID CLAIMS ONLY*/
AND
CSR.CLMSTS_CAT = 2  /*COMPLETED*/
AND
C.DATEKEY >= DATEADD( YEAR, -5, GETDATE() )

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #AllClaimLines ORDER BY PersonID, [Incurred Date]
/************************************************************************************************************/
/*STORE THE TABLE INTO MY DATABASE*/

IF OBJECT_ID('DEPT_Actuary_JMarx.dbo.[PersonHistory-Opioids]') IS NOT NULL DROP TABLE DEPT_Actuary_JMarx.dbo.[PersonHistory-Opioids];

SELECT
 PersonID
,[PAT_KEY]
,[Incurred Date]
INTO
DEPT_Actuary_JMarx.dbo.[PersonHistory-Opioids]
FROM 
#AllClaimLines
ORDER BY
 PersonID
,[Incurred Date];

/*************************************************************************************************************************/
/*ADD A ROW TO THE TRANSACTION LOG*/

EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Executed'
	,@TransactionComment = 'The procedure to update the PersonHistory-Opioids table was executed. Success/Failure/Error state unknown.'
	,@TransactionName =  @TransactionName
GO
