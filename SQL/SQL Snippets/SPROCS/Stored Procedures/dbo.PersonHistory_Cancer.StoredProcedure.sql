USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[PersonHistory_Cancer]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PersonHistory_Cancer]

AS

/**********************************************************************************/
/* DECLARE INITIAL PARAMETERS FOR THE TRANSACTION LOG */

DECLARE 
 @TransactionName			VARCHAR(1000) = ( '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME( @@PROCID ) + '].[' + OBJECT_NAME( @@PROCID ) + ']')
,@TransactionDescription	VARCHAR(1000) = 'Update the PersonHistory-Cancer Table';

/*****************************************************************************************************************************/
/* AUTHOR: JARED MARX */
/* CREATION DATE: 2016-06-22*/
/*****************************************************************************************************************************/
/*
VERSIONS:
V1: 1) CREATE A PERSON-DATE TABLE FOR ALL CANCER CODES
*/
/*****************************************************************************************************************************/
/* 
PROCESS:
1) CREATE A LIST OF DIAGNOSIS CODES FOR CANCER
2) FIND ALL DATES FOR A MEMBER THAT INVOLVES CANCER
*/

/************************************************************************************************************/
/*CREATE A X-WALK FOR DIAGNOSIS CODES*/

IF OBJECT_ID('tempdb..#CancerDiagnosis') IS NOT NULL DROP TABLE #CancerDiagnosis;

SELECT DISTINCT 
[DIAGKEY]
INTO #CancerDiagnosis
FROM 
[wea_dw].[DMLIB].[ICD_DIAG_CD_REF]
WHERE
(
ODIAG BETWEEN  '1400' AND '23999'
AND 
DIAG_TYP = 'ICD-9' 
)
OR
(
DIAG_TYP = 'ICD-10'
AND
ODIAG BETWEEN 'C00' AND 'D4999'
)

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #CancerDiagnosis

/************************************************************************************************************/
/*FIND ALL THE DIAG PERSON-DATES*/

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

	LEFT JOIN wea_dw.DMLIB.CLMLN_DIAG AS CLDiag
		ON CLDiag.CLMLN_KEY = CLF.CLMLN_KEY

		JOIN #CancerDiagnosis AS Cancer
			ON Cancer.DIAGKEY = CLDiag.DIAGKEY

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

IF OBJECT_ID('DEPT_Actuary_JMarx.dbo.[PersonHistory-Cancer]') IS NOT NULL DROP TABLE DEPT_Actuary_JMarx.dbo.[PersonHistory-Cancer];

SELECT
 PersonID
,[PAT_KEY]
,[Incurred Date]
INTO DEPT_Actuary_JMarx.dbo.[PersonHistory-Cancer]
FROM 
#AllClaimLines
ORDER BY
 PersonID
,[Incurred Date];
/*************************************************************************************************************************/
/*ADD A ROW TO THE TRANSACTION LOG*/

EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Executed'
	,@TransactionComment = 'The procedure to update the PersonHistory-Cancer table was executed. Success/Failure/Error state unknown.'
	,@TransactionName =  @TransactionName
GO
