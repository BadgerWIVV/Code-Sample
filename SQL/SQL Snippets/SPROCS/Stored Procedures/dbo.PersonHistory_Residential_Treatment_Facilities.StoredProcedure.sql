USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[PersonHistory_Residential_Treatment_Facilities]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PersonHistory_Residential_Treatment_Facilities]

AS

/**********************************************************************************/
/* DECLARE INITIAL PARAMETERS FOR THE TRANSACTION LOG */

DECLARE 
 @TransactionName			VARCHAR(1000) = ( '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME( @@PROCID ) + '].[' + OBJECT_NAME( @@PROCID ) + ']')
,@TransactionDescription	VARCHAR(1000) = 'Update the PersonHistory-Residential Treatment Facilities Table';

/*****************************************************************************************************************************/
/* AUTHOR: JARED MARX */
/* CREATION DATE: 2016-06-22*/
/*****************************************************************************************************************************/
/*
VERSIONS:
V1: 1) CREATE A PERSON-DATE TABLE FOR ALL RESIDENTIAL TREATMENT FACILITY CODES
*/
/*****************************************************************************************************************************/
/* 
PROCESS:
1) CREATE A LIST OF TOB CODES
2) FIND ALL DATES FOR A MEMBER THAT INVOLVES RESIDENTIAL TREATMENT FACILITIES
*/

/************************************************************************************************************/
/*FIND ALL THE TOB PERSON-DATES*/

IF OBJECT_ID('tempdb..#TOB') IS NOT NULL DROP TABLE #TOB;

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

WHERE 
ClDim.[DUPLIC] = 'N'
AND
CSR.CLMSTS IN (' P' )/*PAID CLAIMS ONLY*/
AND
CSR.CLMSTS_CAT = 2  /*COMPLETED*/
AND
C.DATEKEY >= DATEADD( YEAR, -5, GETDATE() )
AND
ClDim.[TYPBIL] IN ('861','862','863','864','865','866','867')

/*FOR DEBUGGING*/ --SELECT TOP 1000 * FROM #TOB ORDER BY PersonID, [Incurred Date]

/************************************************************************************************************/
/*STORE THE TABLE INTO MY DATABASE*/

IF OBJECT_ID('DEPT_Actuary_JMarx.dbo.[PersonHistory-Residential Treatment Facility]') IS NOT NULL DROP TABLE DEPT_Actuary_JMarx.dbo.[PersonHistory-Residential Treatment Facility];

SELECT
 PersonID
,[PAT_KEY]
,[Incurred Date]
INTO DEPT_Actuary_JMarx.dbo.[PersonHistory-Residential Treatment Facility]
FROM 
#AllClaimLines
ORDER BY
 PersonID
,[Incurred Date];
/*************************************************************************************************************************/
/*ADD A ROW TO THE TRANSACTION LOG*/

EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Executed'
	,@TransactionComment = 'The procedure to update the PersonHistory-Residential Treatment Facilities table was executed. Success/Failure/Error state unknown.'
	,@TransactionName =  @TransactionName
GO
