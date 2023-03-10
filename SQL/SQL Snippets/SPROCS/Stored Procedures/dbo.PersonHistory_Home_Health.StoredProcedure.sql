USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[PersonHistory_Home_Health]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PersonHistory_Home_Health]

AS

/**********************************************************************************/
/* DECLARE INITIAL PARAMETERS FOR THE TRANSACTION LOG */

DECLARE 
 @TransactionName			VARCHAR(1000) = ( '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME( @@PROCID ) + '].[' + OBJECT_NAME( @@PROCID ) + ']')
,@TransactionDescription	VARCHAR(1000) = 'Update the PersonHistory-Home Health Table';

/*****************************************************************************************************************************/
/* AUTHOR: JARED MARX */
/* CREATION DATE: 2016-06-22*/
/*****************************************************************************************************************************/
/*
VERSIONS:
V1: 1) CREATE A PERSON-DATE TABLE FOR ALL HOME HEALTH CODES
*/
/*****************************************************************************************************************************/
/* 
PROCESS:
1) CREATE A LIST OF TOB AND REV CODES
2) FIND ALL DATES FOR A MEMBER THAT INVOLVES HOME HEALTH
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
REV.REVUCD IN ('0560','0562','0569','0570','0579','0580','0589','0590','0600')


/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #Revenue

/************************************************************************************************************/
/*FIND ALL THE DIAG PERSON-DATES*/

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
/*FIND ALL THE TOB PERSON-DATES*/

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
ClDim.[TYPBIL] IN ('321','322','323','324','327','329','331','332','333','334','335','337','339','340','341','342','343','344','347')

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #TOB ORDER BY PersonID, [Incurred Date]
/************************************************************************************************************/
/*FIND ALL THE HOME HEALTH PERSON DATES*/

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

IF OBJECT_ID('DEPT_Actuary_JMarx.dbo.[PersonHistory-Home Health]') IS NOT NULL DROP TABLE DEPT_Actuary_JMarx.dbo.[PersonHistory-Home Health];

SELECT
 PersonID
,[PAT_KEY]
,[Incurred Date]
INTO DEPT_Actuary_JMarx.dbo.[PersonHistory-Home Health]
FROM 
#AllClaimLines
ORDER BY
 PersonID
,[Incurred Date];
/*************************************************************************************************************************/
/*ADD A ROW TO THE TRANSACTION LOG*/

EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Executed'
	,@TransactionComment = 'The procedure to update the PersonHistory-Home Health table was executed. Success/Failure/Error state unknown.'
	,@TransactionName =  @TransactionName
GO
