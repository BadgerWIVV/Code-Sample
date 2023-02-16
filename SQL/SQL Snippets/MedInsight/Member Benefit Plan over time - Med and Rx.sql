SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/* 
7/3/2019	1:16:33	264,542 rows
*/

/**************************************************************************************************************/
/* INITIALIZE THE TEMP TABLE */

USE HCI_Stage;
GO

IF OBJECT_ID( 'HCI_STAGE.jcm.ENROLLMENT_SEGMENTS' ) IS NOT NULL
	BEGIN
		DROP TABLE ENROLLMENT_SEGMENTS
	END;


/**************************************************************************************************************/
/* ACQUIRE THE ENROLLMENT FOR A MEMBER FOR EACH DAY */

SET NOCOUNT ON;

WITH #MemberBenefitPlan AS (
SELECT
 DATE_KEY
,DATE_VALUE
,YEAR_NUMBER
,MONTH_NUMBER
,CONCAT( CAST( YEAR_NUMBER AS VARCHAR( 4 ) ), 
		CASE WHEN LEN( MONTH_NUMBER ) = 1 THEN CONCAT( '0', CAST( MONTH_NUMBER AS VARCHAR( 1 ) ) )
			 ELSE CAST( MONTH_NUMBER AS VARCHAR ( 2 ) )
			 END ) AS 'YEAR_MONTH'
,AHF.ACCOUNT_KEY
,AHF.ACCOUNT_NAME
,MHF.MEMBER_HCC_ID
,BPTC.BENEFIT_PLAN_TYPE_NAME
FROM 
[wea_prod_dw].[dbo].[DATE_DIMENSION] AS DateDim

	LEFT JOIN [wea_prod_dw].[dbo].[ACCOUNT_HISTORY_FACT] AS AHF
		ON DateDim.DATE_KEY BETWEEN AHF.VERSION_EFF_DATE_KEY AND AHF.VERSION_EXP_DATE_KEY - 1

		LEFT JOIN [wea_prod_dw].[dbo].[MEMBER_HISTORY_FACT] AS MHF
			ON MHF.ACCOUNT_KEY = AHF.ACCOUNT_KEY
			AND DateDim.DATE_KEY BETWEEN MHF.VERSION_EFF_DATE_KEY AND MHF.VERSION_EXP_DATE_KEY - 1

			LEFT JOIN [wea_prod_dw].[dbo].[MEMBER_HIST_FACT_TO_BNFT_PLAN] AS MHFToBP
				ON MHFToBP.MEMBER_HISTORY_FACT_KEY = MHF.MEMBER_HISTORY_FACT_KEY

				LEFT JOIN [wea_prod_dw].[dbo].[BENEFIT_PLAN_HISTORY_FACT] AS BPHF
					ON BPHF.BENEFIT_PLAN_KEY = MHFToBP.BENEFIT_PLAN_KEY
					AND DateDim.DATE_KEY BETWEEN BPHF.VERSION_EFF_DATE_KEY AND BPHF.VERSION_EXP_DATE_KEY - 1

					LEFT JOIN wea_prod_dw.[dbo].[BNFT_PLN_HST_FCT_TO_NEDEF_COMP] AS BenefitPlan2NetworkDefinition
						ON BenefitPlan2NetworkDefinition.[BNFT_PLAN_HST_FCT_KEY] = BPHF.BENEFIT_PLAN_HISTORY_FACT_KEY

						LEFT JOIN wea_prod_dw.[dbo].[NETWORK_DEF_COMP_HIST_FACT] AS NetworkDefinitionComponentHistoryFact
							ON NetworkDefinitionComponentHistoryFact.[NETWORK_DEF_COMP_KEY] = BenefitPlan2NetworkDefinition.[NETWORK_DEF_COMP_KEY]
							AND DateDim.DATE_KEY BETWEEN NetworkDefinitionComponentHistoryFact.VERSION_EFF_DATE_KEY AND NetworkDefinitionComponentHistoryFact.VERSION_EXP_DATE_KEY - 1 

					LEFT JOIN wea_prod_dw.dbo.PRODUCT AS PRODUCT
						ON PRODUCT.PRODUCT_KEY = BPHF.BENEFIT_PLAN_PRODUCT_KEY

						LEFT JOIN [wea_prod_dw].[dbo].[BENEFIT_PLAN_TYPE_CODE] AS BPTC
							ON BPTC.BENEFIT_PLAN_TYPE_KEY = PRODUCT.BENEFIT_PLAN_TYPE_KEY

WHERE 
/*
DAY_OF_MONTH = '15'
AND
*/
YEAR_NUMBER BETWEEN CASE WHEN ( YEAR( GETDATE() ) - 5 ) >= 2013 THEN ( YEAR( GETDATE() ) - 5 )
						 ELSE 2013
						 END
						 AND YEAR( GETDATE() )
AND
BENEFIT_PLAN_STATUS = 'a' /* Active Plans Only*/
AND
BPTC.BENEFIT_PLAN_TYPE_CODE IN (
 '1' /* Medical LOB Only */
,'3' /* Pharmacy */
)
GROUP BY
 DATE_KEY
,DATE_VALUE
,YEAR_NUMBER
,MONTH_NUMBER
,CONCAT( CAST( YEAR_NUMBER AS VARCHAR( 4 ) ), 
		CASE WHEN LEN( MONTH_NUMBER ) = 1 THEN CONCAT( '0', CAST( MONTH_NUMBER AS VARCHAR( 1 ) ) )
			 ELSE CAST( MONTH_NUMBER AS VARCHAR ( 2 ) )
			 END ) 
,AHF.ACCOUNT_KEY
,AHF.ACCOUNT_NAME
,MHF.MEMBER_HCC_ID
,BPTC.BENEFIT_PLAN_TYPE_NAME

),

/**************************************************************************************************************/
/* CREATE A TEMP TABLE OF THE DAILY MEMBERSHIP 
		- TURN THIS INTO THE ENROLLMENT FILE */

#DailyMembership AS (

SELECT
 MEMBER_HCC_ID
,[DATE_VALUE] = 
	CONVERT( VARCHAR, CAST( DATE_VALUE AS DATE ), 23 ) 
,BENEFIT_PLAN_TYPE_NAME
/*
INTO
#DailyMembership
*/
FROM
#MemberBenefitPlan
GROUP BY
 MEMBER_HCC_ID
,DATE_VALUE
,BENEFIT_PLAN_TYPE_NAME

),

/* FOR DEBUGGING */ /* SELECT TOP 100 * FROM #DailyMembership */

/*

SELECT
*
INTO
JMARX.REPORT.[DAILY-MEMBERSHIP-TEST]
FROM
#DailyMembership



IF OBJECT_ID( 'TEMPDB.DBO.#DailyMembership' ) IS NULL
	BEGIN

		SELECT
		*
		INTO
		#DailyMembership
		FROM
		JMARX.REPORT.[DAILY-MEMBERSHIP-TEST]

	END

*/

/**************************************************************************************************************/
/* IDENTIFY GAPS IN ENROLLMENT */

#LeadLag AS (
SELECT
 MEMBER_HCC_ID
,[DATE_VALUE]
,BENEFIT_PLAN_TYPE_NAME
,[Next Available Date] =
	LEAD( DATE_VALUE ) OVER( PARTITION BY MEMBER_HCC_ID, BENEFIT_PLAN_TYPE_NAME ORDER BY DATE_VALUE )
,[Previous Available Date] =
	LAG( DATE_VALUE ) OVER( PARTITION BY MEMBER_HCC_ID, BENEFIT_PLAN_TYPE_NAME ORDER BY DATE_VALUE )
FROM
#DailyMembership
/*
WHERE
MEMBER_HCC_ID = '740000187-02'
*/

),

/**************************************************************************************************************/
/* QUANTIFY THE SIZE OF THE GAPS IN ENROLLMENT */

#Gaps AS (
SELECT
*
,[Gap to Next Date] =
	DATEDIFF( DAY, DATE_VALUE, [Next Available Date] )
,[Gap to Previous Date] =
	DATEDIFF( DAY, [Previous Available Date], DATE_VALUE )

FROM
#LeadLag

),

/**************************************************************************************************************/
/* USE THE SIZE TO DICTATE START/STOP POINTS */

#StartStops AS (
SELECT
*
,[End of Enrollment Indicator] =
	CASE
		WHEN [Gap to Next Date] > 1 OR [Gap to Next Date] IS NULL  THEN 1
		ELSE 0
	END
,[Start of Enrollment Indicator] =
	CASE
		WHEN [Gap to Previous Date] > 1 OR [Gap to Previous Date] IS NULL  THEN 1
		ELSE 0
	END
FROM
#Gaps

),

/**************************************************************************************************************/
/* ORDER THE START/STOP POINTS TO JOIN THEM */

#OrderedStartsStops AS (
SELECT
 MEMBER_HCC_ID
,DATE_VALUE
,BENEFIT_PLAN_TYPE_NAME
,[Start of Enrollment Indicator]
,[End of Enrollment Indicator]
,[Start Order] =
	ROW_NUMBER() OVER ( PARTITION BY [Start of Enrollment Indicator], MEMBER_HCC_ID, BENEFIT_PLAN_TYPE_NAME ORDER BY DATE_VALUE )
,[End Order] =
	ROW_NUMBER() OVER ( PARTITION BY [End of Enrollment Indicator], MEMBER_HCC_ID, BENEFIT_PLAN_TYPE_NAME ORDER BY DATE_VALUE )
FROM
#StartStops
WHERE
[Start of Enrollment Indicator] = 1
OR
[End of Enrollment Indicator] = 1

)

/**************************************************************************************************************/
/* COMBINE START/STOP POINTS TO MAKE ENROLLMENT SEGMENTS */

SELECT
 Starts.MEMBER_HCC_ID
,Starts.BENEFIT_PLAN_TYPE_NAME
,[EFF_DATE] =
	Starts.DATE_VALUE
,[TERM_DATE] =
	Stops.DATE_VALUE
INTO
HCI_STAGE.jcm.ENROLLMENT_SEGMENTS
FROM
#OrderedStartsStops AS Starts

	LEFT JOIN #OrderedStartsStops AS Stops
		ON Starts.MEMBER_HCC_ID = Stops.MEMBER_HCC_ID
		AND Starts.BENEFIT_PLAN_TYPE_NAME = Stops.BENEFIT_PLAN_TYPE_NAME
		AND Starts.[Start Order] = Stops.[End Order]

WHERE
Starts.[Start of Enrollment Indicator] = 1
AND
Stops.[End of Enrollment Indicator] = 1
ORDER BY
 MEMBER_HCC_ID
,[EFF_DATE]
