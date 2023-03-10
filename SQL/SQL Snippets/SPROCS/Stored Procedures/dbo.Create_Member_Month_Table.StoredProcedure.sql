USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[Create_Member_Month_Table]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[Create_Member_Month_Table] AS

BEGIN

DECLARE
 @TransactionName			VARCHAR(1000) = ( '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME( @@PROCID ) + '].[' + OBJECT_NAME( @@PROCID ) + ']')
,@TransactionDescription	VARCHAR(1000) = 'Recreate the member month table'
,@PriorRowCount				INT
,@PostRowCount				INT
;



/****************************************************************************************/
/*COUNT THE ROWS IN THE TABLE PRIOR TO THE EXECUTION*/

SET
@PriorRowCount = ( SELECT COUNT(*) FROM DEPT_Actuary_JMarx.dbo.Member_Months );

/****************************************************************************************/
/*DELETE THE TABLE IN PREPARATION*/

IF OBJECT_ID('DEPT_Actuary_JMarx.dbo.Member_Months') IS NOT NULL DROP TABLE DEPT_Actuary_JMarx.dbo.Member_Months;


/****************************************************************************************/
/*CREATE A MEMBERSHIP COUNT BY MONTH*/

WITH MemberMonths AS (

SELECT 
 DD.YEAR_MONTH
,DD.YEAR
,DD.MONTH
,DD.YEAR_QUARTER
,CASE WHEN LEN( DD.MONTH ) = 1 THEN CONCAT(DD.YEAR,'-0',DD.MONTH) 
	  ELSE CONCAT(DD.YEAR,'-',DD.MONTH)
	  END AS 'Year-Month'
,SUM([MEM_CNT]) AS 'Member Months'
FROM 
[wea_dw].[DMLIB].[MBR_PLN_FACT_AGG] AS MPFA
	
	JOIN [wea_dw].[DMLIB].[DATE_DIM] AS DD 
		ON DD.DATE_KEY = MPFA.DATE_KEY
	
	JOIN [wea_dw].[DMLIB].[GRP_PLN_SA] AS GPS 
		ON GPS.UNPLNSAKEY = MPFA.UNPLNSAKEY
		
		LEFT JOIN [wea_dw].[DMLIB].[PLN_TYP_CD_REF] AS P
			ON P.PLNTYPKEY = GPS.PLNTYPKEY
WHERE 
GPS.LOB = 1 /*MEDICAL LOB ONLY*/
AND
LTRIM( RTRIM( P.SLF_FND_IND ) ) = '' /*EXCLUDE SELF FUNDED MEMBERS*/
GROUP BY 
 DD.YEAR_MONTH
,DD.YEAR
,DD.YEAR_QUARTER
,DD.MONTH
,CASE WHEN LEN( DD.MONTH ) = 1 THEN CONCAT(DD.YEAR,'-0',DD.MONTH) 
	  ELSE CONCAT(DD.YEAR,'-',DD.MONTH)
	  END

),

/****************************************************************************************/
/*AGGREGATE THE MONTHLY MEMBERSHIP TO A YEARLY MEMBERSHIP*/

YearlyMembership AS (

SELECT
 A.YEAR
,SUM( A.[Member Months] ) / COUNT ( A.Month ) AS 'Yearly Membership'
FROM 
MemberMonths AS A
GROUP BY 
A.Year

),

/****************************************************************************************/
/*AGGREGATE THE MONTHLY MEMBERSHIP TO A QUARTERLY MEMBERSHIP*/

QuarterlyMembership AS (

SELECT
 A.YEAR_QUARTER
,SUM( A.[Member Months] ) / COUNT ( A.Month ) AS 'Quarterly Membership'
FROM 
MemberMonths AS A
GROUP BY 
A.YEAR_QUARTER

)

/****************************************************************************************/
/*COMBINE MONTH, QUARTERLY, AND YEARLY RESULTS TO THE OUTPUT*/

SELECT 
 B.Year_Month
,B.Year
,B.YEAR_QUARTER
,RIGHT( B.YEAR_QUARTER,1 ) AS 'INCURRED_CAL_QUARTER'
,B.Month
,B.[Year-Month]
,B.[Member Months]
,D.[Quarterly membership]
,C.[yearly membership]
INTO 
[DEPT_Actuary_JMarx].[dbo].[Member_Months]
FROM 
MemberMonths AS B
	
	JOIN YearlyMembership AS C
		ON C.Year = B.Year

	JOIN QuarterlyMembership AS D
		ON D.YEAR_QUARTER = B.YEAR_QUARTER

END

/****************************************************************************************/
/*COUNT THE ROWS POST THE EXECUTION*/

SET
@PostRowCount = ( SELECT COUNT(*) FROM DEPT_Actuary_JMarx.dbo.Member_Months );

/****************************************************************************************/
/*ADD A ROW TO THE TRANSACTION LOG*/

IF @PostRowCount > 0
 BEGIN 
	EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
		,@TransactionStatus = 'Success'
		,@TransactionComment = 'The table was recreated'
		,@TransactionName =  @TransactionName
 END

ELSE
 BEGIN
	EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Failure'
	,@TransactionComment = 'The table was unable to be recreated'
	,@TransactionName =  @TransactionName
 END
GO
