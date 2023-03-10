USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[PersonHistory_Drug_Testing]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PersonHistory_Drug_Testing]

AS

/**********************************************************************************/
/* DECLARE INITIAL PARAMETERS FOR THE TRANSACTION LOG */

DECLARE 
 @TransactionName			VARCHAR(1000) = ( '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME( @@PROCID ) + '].[' + OBJECT_NAME( @@PROCID ) + ']')
,@TransactionDescription	VARCHAR(1000) = 'Update the PersonHistory-Drug Testing Table';

/*****************************************************************************************************************************/
/* AUTHOR: JARED MARX */
/* CREATION DATE: 2016-06-22*/
/*****************************************************************************************************************************/
/*
VERSIONS:
V1: 1) CREATE A PERSON-DATE TABLE FOR ALL DRUG TESTING CPT/HCPCS CODES
*/
/*****************************************************************************************************************************/
/* 
PROCESS:
1) CREATE A LIST OF CPT/HCPCS CODES BASED ON VARIOUS DRUG TESTING POLICIES
2) FIND ALL DATES FOR A MEMBER THAT INVOLVES A DRUG TEST
*/

/*****************************************************************************************************************************/
/*FIND ALL CPTS RELATED TO DRUG TESTING*/
/*****************************************************************************************************************************/
/*FIND ALL CPTS IDENTIFIED BY MEDTOX 2014*/

IF OBJECT_ID('tempdb..#MedTox2014') IS NOT NULL DROP TABLE #MedTox2014

SELECT DISTINCT
[CPT 2014] AS 'CPT'
,'MedTox' AS 'Source'
INTO #MedTox2014
FROM DEPT_Actuary_JMarx.dbo.[UDT-MedTox_Drug_CPT_List_2016-01-05]

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #MedTox2014
/*****************************************************************************************************************************/
/*FIND ALL CPTS IDENTIFIED BY MEDTOX IN 2015*/

IF OBJECT_ID('tempdb..#MedTox2015') IS NOT NULL DROP TABLE #MedTox2015

SELECT DISTINCT
[CPT 2015] AS 'CPT'
,'MedTox' AS 'Source'
INTO #MedTox2015
FROM DEPT_Actuary_JMarx.dbo.[UDT-MedTox_Drug_CPT_List_2016-01-05]

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #MedTox2015
/*****************************************************************************************************************************/
/*FIND ALL CPTS IDENTIFIED BY MODA*/

IF OBJECT_ID('tempdb..#Moda') IS NOT NULL DROP TABLE #Moda

SELECT DISTINCT
[Procedure Code] AS 'CPT'
,'Moda' AS 'Source'
INTO #Moda
FROM DEPT_Actuary_JMarx.dbo.[UDT-ModaHealth_Drug_CPT_List_2016-01-05]

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #Moda
/*****************************************************************************************************************************/
/*FIND ALL CPTS IDENTIFIED BY MEDTOX*/

IF OBJECT_ID('tempdb..#MedTox') IS NOT NULL DROP TABLE #MedTox

SELECT 
CPT
INTO #MedTox
FROM #MedTox2014
UNION
SELECT
CPT
FROM #MedTox2015

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #MedTox
/*****************************************************************************************************************************/
/*CREATE A LIST OF ALL POSSIBLE CPT CODES THAT ARE DRUG TEST RELATED*/

IF OBJECT_ID('tempdb..#DrugTestList') IS NOT NULL DROP TABLE #DrugTestList

SELECT
CPT
INTO #DrugTestList
FROM #MedTox
UNION
SELECT
CPT
FROM #Moda

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #DrugTestList

/************************************************************************************************************/
/*PULL ALL CLAIM LINES ASSOCIATED TO THE MEMBERS THIS WILL BE USED TO IDENTIFY  DRUG TESTING*/

IF OBJECT_ID('tempdb..#AllClaimLines') IS NOT NULL DROP TABLE #AllClaimLines;

SELECT DISTINCT
 Person.PersonID
,CF.[PAT_KEY]
,C.DATEKEY AS 'Incurred Date'
INTO #AllClaimLines
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

		LEFT JOIN wea_dw.DMLIB.SRVC_CD_REF AS CPT
			ON CPT.SVC_CD_KEY = ClDim.SVC_CD_KEY

			JOIN #DrugTestList AS UDT
				ON UDT.CPT = CPT.SVC_CD

WHERE
ClDim.[DUPLIC] = 'N'
AND
CSR.CLMSTS IN (' P' )/*PAID CLAIMS ONLY*/
AND
CSR.CLMSTS_CAT = 2  /*COMPLETED*/
AND
C.DATEKEY >= DATEADD( YEAR, -5, GETDATE() )


/*FOR DEBUGGING*/ --SELECT TOP 100 * FROM #AllClaimLines ORDER BY PersonID, [Incurred Date] 

/************************************************************************************************************/
/*STORE THE TABLE INTO MY DATABASE*/

IF OBJECT_ID('DEPT_Actuary_JMarx.dbo.[PersonHistory-DrugTesting]') IS NOT NULL DROP TABLE DEPT_Actuary_JMarx.dbo.[PersonHistory-DrugTesting];

SELECT
 PersonID
,[PAT_KEY]
,[Incurred Date]
INTO DEPT_Actuary_JMarx.dbo.[PersonHistory-DrugTesting]
FROM 
#AllClaimLines
ORDER BY
 PersonID
,[Incurred Date];
/*************************************************************************************************************************/
/*ADD A ROW TO THE TRANSACTION LOG*/

EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Executed'
	,@TransactionComment = 'The procedure to update the PersonHistory-Drug Testing table was executed. Success/Failure/Error state unknown.'
	,@TransactionName =  @TransactionName
GO
