USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[PersonHistory_Hospice]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PersonHistory_Hospice]

AS

/**********************************************************************************/
/* DECLARE INITIAL PARAMETERS FOR THE TRANSACTION LOG */

DECLARE 
 @TransactionName			VARCHAR(1000) = ( '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME( @@PROCID ) + '].[' + OBJECT_NAME( @@PROCID ) + ']')
,@TransactionDescription	VARCHAR(1000) = 'Update the PersonHistory-Hospice Table';

/*****************************************************************************************************************************/
/* AUTHOR: JARED MARX */
/* CREATION DATE: 2016-06-22*/
/*****************************************************************************************************************************/
/*
VERSIONS:
V1: 1) CREATE A PERSON-DATE TABLE FOR ALL HOSPICE CODES
*/
/*****************************************************************************************************************************/
/* 
PROCESS:
1) CREATE A LIST OF TOB, POS, AND REV CODES
2) FIND ALL DATES FOR A MEMBER THAT INVOLVES HOSPICE
*/

/************************************************************************************************************/
/*CREATE A X-WALK FOR REVENUE CODES*/

IF OBJECT_ID('tempdb..#Revenue') IS NOT NULL DROP TABLE #Revenue;

SELECT DISTINCT 
RVUCODKEY
INTO #Revenue
FROM 
[wea_dw].[DMLIB].[REV_CD_REF] AS REV
WHERE
 REV.REVUCD IN ('0115','0125','0135','0145','0155','0235','0650','0658','0659')

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #Revenue

/************************************************************************************************************/
/*FIND ALL THE REVENUE CODE PERSON-DATES*/

IF OBJECT_ID('tempdb..#Rev') IS NOT NULL DROP TABLE #Rev;

SELECT DISTINCT
 Person.PersonID
,CF.[PAT_KEY]
,C.DATEKEY AS 'Incurred Date'
INTO 
#Rev
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

		JOIN #Revenue AS Revenue
			ON ClDim.RVUCODKEY = Revenue.RVUCODKEY

WHERE 
ClDim.[DUPLIC] = 'N'
AND
CSR.CLMSTS IN (' P' )/*PAID CLAIMS ONLY*/
AND
CSR.CLMSTS_CAT = 2  /*COMPLETED*/
AND
C.DATEKEY >= DATEADD( YEAR, -5, GETDATE() )

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #Rev ORDER BY PersonID, [Incurred Date]
/************************************************************************************************************/
/*FIND ALL THE TOB AND POS PERSON-DATES*/

IF OBJECT_ID('tempdb..#TOB') IS NOT NULL DROP TABLE #TOB;

SELECT DISTINCT
 Person.PersonID
,CF.[PAT_KEY]
,C.DATEKEY AS 'Incurred Date'
INTO 
#TOB
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
		
		LEFT JOIN [wea_dw].[DMLIB].[PLC_SRVC_CD_REF] AS POS 
			ON POS.PLCSVCKEY = ClDim.PLCSVCKEY

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
AND
(
POS.PLCSVC_CD = 34 
OR
ClDim.[TYPBIL] IN ('810','811','812','813','814','815','817','821','822','823','824')
)

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #TOB ORDER BY PersonID, [Incurred Date]
/************************************************************************************************************/
/*FIND ALL THE HOSPICE PERSON DATES*/

IF OBJECT_ID('tempdb..#AllClaimLines') IS NOT NULL DROP TABLE #AllClaimLines;

SELECT
 PersonID
,[PAT_KEY]
,[Incurred Date]
INTO #AllClaimLines
FROM
#TOB

UNION

SELECT
 PersonID
,[PAT_KEY]
,[Incurred Date]
FROM
#Rev

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #AllClaimLines ORDER BY PersonID, [Incurred Date]
/************************************************************************************************************/
/*STORE THE TABLE INTO MY DATABASE*/

IF OBJECT_ID('DEPT_Actuary_JMarx.dbo.[PersonHistory-Hospice]') IS NOT NULL DROP TABLE DEPT_Actuary_JMarx.dbo.[PersonHistory-Hospice];

SELECT
 PersonID
,[PAT_KEY]
,[Incurred Date]
INTO DEPT_Actuary_JMarx.dbo.[PersonHistory-Hospice]
FROM 
#AllClaimLines
ORDER BY
 PersonID
,[Incurred Date];
/*************************************************************************************************************************/
/*ADD A ROW TO THE TRANSACTION LOG*/

EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Executed'
	,@TransactionComment = 'The procedure to update the PersonHistory-Hospice table was executed. Success/Failure/Error state unknown.'
	,@TransactionName =  @TransactionName
GO
