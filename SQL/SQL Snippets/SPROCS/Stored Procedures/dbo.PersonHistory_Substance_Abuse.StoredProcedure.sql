USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[PersonHistory_Substance_Abuse]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PersonHistory_Substance_Abuse]

AS

/**********************************************************************************/
/* DECLARE INITIAL PARAMETERS FOR THE TRANSACTION LOG */

DECLARE 
 @TransactionName			VARCHAR(1000) = ( '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME( @@PROCID ) + '].[' + OBJECT_NAME( @@PROCID ) + ']')
,@TransactionDescription	VARCHAR(1000) = 'Update the PersonHistory-Substance Abuse Table';

/*****************************************************************************************************************************/
/* AUTHOR: JARED MARX */
/* CREATION DATE: 2016-06-22*/
/*****************************************************************************************************************************/
/*
VERSIONS:
V1: 1) CREATE A PERSON-DATE TABLE FOR ALL SUBSTANCE ABUSE CODES
*/
/*****************************************************************************************************************************/
/* 
PROCESS:
1) CREATE A LIST OF DIAGNOSIS CODES BASED ON VIRGINIA'S POLICY LIST /*https://www.scc.virginia.gov/boi/co/health/ltcmed/cpt_codes.pdf*/
2) FIND ALL DATES FOR A MEMBER THAT INVOLVES SUBSTANCE ABUSE
*/

/************************************************************************************************************/
/*CREATE A X-WALK FOR DIAGNOSIS CODES*/

IF OBJECT_ID('tempdb..#AbuseDiagnosis') IS NOT NULL DROP TABLE #AbuseDiagnosis;

SELECT DISTINCT 
[DIAGKEY]
INTO #AbuseDiagnosis
FROM 
[wea_dw].[DMLIB].[ICD_DIAG_CD_REF]
WHERE
(
SPCFCTY34 IN ( '291', '303', '292','304','305' ) 
AND 
DIAG_TYP = 'ICD-9' 
)
OR
(
DIAG_TYP = 'ICD-10'
AND
SPCFCTY34 IN ( 'F10', 'F11', 'F12', 'F13','F14', 'F15', 'F16','F18', 'F19' ) 
)

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #AbuseDiagnosis

/************************************************************************************************************/
/*CREATE A X-WALK FOR CPT CODES*/

IF OBJECT_ID('tempdb..#AbuseCPT') IS NOT NULL DROP TABLE #AbuseCPT;

SELECT DISTINCT 
SVC_CD_KEY
INTO #AbuseCPT
FROM 
wea_dw.DMLIB.SRVC_CD_REF AS CPT
WHERE
CPT.SVC_CD IN ( '80100','80101','80102','80103','80104' )

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #AbuseCPT

/************************************************************************************************************/
/*FIND ALL THE DIAG PERSON-DATES*/

IF OBJECT_ID('tempdb..#Diag') IS NOT NULL DROP TABLE #Diag;

SELECT DISTINCT
 Person.PersonID
,CF.[PAT_KEY]
,C.DATEKEY AS 'Incurred Date'
INTO 
#Diag
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

	LEFT JOIN wea_dw.DMLIB.CLMLN_DIAG AS CLDiag
		ON CLDiag.CLMLN_KEY = CLF.CLMLN_KEY

		JOIN #AbuseDiagnosis AS Abuse
			ON Abuse.DIAGKEY = CLDiag.DIAGKEY

WHERE 
ClDim.[DUPLIC] = 'N'
AND
CSR.CLMSTS IN (' P' )/*PAID CLAIMS ONLY*/
AND
CSR.CLMSTS_CAT = 2  /*COMPLETED*/
AND
C.DATEKEY >= DATEADD( YEAR, -5, GETDATE() )

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #Diag ORDER BY PersonID, [Incurred Date]
/************************************************************************************************************/
/*FIND ALL THE CPT PERSON-DATES*/

IF OBJECT_ID('tempdb..#CPT') IS NOT NULL DROP TABLE #CPT;

SELECT DISTINCT
 Person.PersonID
,CF.[PAT_KEY]
,C.DATEKEY AS 'Incurred Date'
INTO 
#CPT
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

		JOIN #AbuseCPT AS CPT
			ON CPT.SVC_CD_KEY = ClDim.SVC_CD_KEY
			
		LEFT JOIN [wea_dw].[DMLIB].[CLM_STS_REF] AS CSR 
			ON CSR.STATKEY = CLDim.STATKEY

WHERE 
ClDim.[DUPLIC] = 'N'
AND
CSR.CLMSTS IN (' P' )/*PAID CLAIMS ONLY*/
AND
CSR.CLMSTS_CAT = 2  /*COMPLETED*/
AND
C.DATEKEY >= DATEADD( YEAR, -5, GETDATE() )

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #CPT ORDER BY PersonID, [Incurred Date]
/************************************************************************************************************/
/*FIND ALL THE SUBSTANCE ABUSE PERSON DATES*/

IF OBJECT_ID('tempdb..#AllClaimLines') IS NOT NULL DROP TABLE #AllClaimLines;

SELECT
 PersonID
,[PAT_KEY]
,[Incurred Date]
INTO #AllClaimLines
FROM
#CPT

UNION

SELECT
 PersonID
,[PAT_KEY]
,[Incurred Date]
FROM
#Diag

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #AllClaimLines ORDER BY PersonID, [Incurred Date]
/************************************************************************************************************/
/*STORE THE TABLE INTO MY DATABASE*/

IF OBJECT_ID('DEPT_Actuary_JMarx.dbo.[PersonHistory-Substance Abuse]') IS NOT NULL DROP TABLE DEPT_Actuary_JMarx.dbo.[PersonHistory-Substance Abuse];

SELECT
 PersonID
,[PAT_KEY]
,[Incurred Date]
INTO DEPT_Actuary_JMarx.dbo.[PersonHistory-Substance Abuse]
FROM 
#AllClaimLines
ORDER BY
 PersonID
,[Incurred Date];
/*************************************************************************************************************************/
/*ADD A ROW TO THE TRANSACTION LOG*/

EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Executed'
	,@TransactionComment = 'The procedure to update the PersonHistory-Substance Abuse table was executed. Success/Failure/Error state unknown.'
	,@TransactionName =  @TransactionName
GO
