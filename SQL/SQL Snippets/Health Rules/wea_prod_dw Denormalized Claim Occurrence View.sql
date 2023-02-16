USE [HCI]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************************/
/* CREATE THE VIEW */

CREATE VIEW [DN].[wea_prod_dw_CLAIM_OCCURRENCE]  AS 

/**************************************************************************************************************/
/* IDENTIFY THE MAXIMUM NUMBER OF OPTIONS AVAILABLE*/

/* FOR DEBUGGING */ --SELECT MAX( [SORT_ORDER] ) FROM [wea_prod_dw].[dbo].[CLAIM_FACT_TO_OCCURRENCE]

/**************************************************************************************************************/
/* ACQUIRE THE BASE CLAIM OCCURRENCE INFORMATION TO PIVOT */

WITH CTE_Base AS (

SELECT
 Claim2Occurrence.[CLAIM_FACT_KEY]
,Claim2Occurrence.[SORT_ORDER]

,[OCCURRENCE_DATE] =
	CAST( OccurenceDate.DATE_VALUE AS DATE )

,OccurrenceCode.OCCURRENCE_CODE
,[OCCURRENCE_DESCRIPTION] =
	OccurrenceCode.OCCURRENCE_CODE_DESC
FROM
[wea_prod_dw].[dbo].[CLAIM_FACT_TO_OCCURRENCE] AS Claim2Occurrence

	JOIN [wea_prod_dw].[dbo].OCCURRENCE_CODE AS OccurrenceCode
		ON	OccurrenceCode.OCCURRENCE_CODE = Claim2Occurrence.OCCURRENCE_CODE

	JOIN wea_prod_dw.dbo.DATE_DIMENSION AS OccurenceDate
		ON	OccurenceDate.DATE_KEY = Claim2Occurrence.OCCURRENCE_DATE_KEY

GROUP BY
 Claim2Occurrence.[CLAIM_FACT_KEY]
,Claim2Occurrence.[SORT_ORDER]

,OccurenceDate.DATE_VALUE

,OccurrenceCode.OCCURRENCE_CODE
,OccurrenceCode.OCCURRENCE_CODE_DESC
),

/**************************************************************************************************************/
/* PIVOT THE BASE INFORMATION TO GET DENORMALIZED OCCURRENCE CODES */

CTE_OCCURRENCE_CODES AS (

SELECT
 CLAIM_FACT_KEY
,[Claim Occurrence Code 1] =
	[1]
,[Claim Occurrence Code 2] =
	[2]
,[Claim Occurrence Code 3] =
	[3]
,[Claim Occurrence Code 4] =
	[4]
,[Claim Occurrence Code 5] =
	[5]
,[Claim Occurrence Code 6] =
	[6]
,[Claim Occurrence Code 7] =
	[7]
,[Claim Occurrence Code 8] =
	[8]
,[Claim Occurrence Code 9] =
	[9]
,[Claim Occurrence Code 10] =
	[10]
,[Claim Occurrence Code 11] =
	[11]
,[Claim Occurrence Code 12] =
	[12]

FROM (
	SELECT Base.CLAIM_FACT_KEY, Base.SORT_ORDER, Base.OCCURRENCE_CODE FROM CTE_Base AS Base ) AS ImportantColumns
PIVOT( 
	MAX( OCCURRENCE_CODE )
	FOR SORT_ORDER IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12] )
	) AS PivotCodes
),

/**************************************************************************************************************/
/* PIVOT THE BASE INFORMATION TO GET DENORMALIZED OCCURRENCE DATE */

CTE_OCCURRENCE_DATES AS (

SELECT
 CLAIM_FACT_KEY
,[Claim Occurrence Date 1] =
	[1]
,[Claim Occurrence Date 2] =
	[2]
,[Claim Occurrence Date 3] =
	[3]
,[Claim Occurrence Date 4] =
	[4]
,[Claim Occurrence Date 5] =
	[5]
,[Claim Occurrence Date 6] =
	[6]
,[Claim Occurrence Date 7] =
	[7]
,[Claim Occurrence Date 8] =
	[8]
,[Claim Occurrence Date 9] =
	[9]
,[Claim Occurrence Date 10] =
	[10]
,[Claim Occurrence Date 11] =
	[11]
,[Claim Occurrence Date 12] =
	[12]
FROM (
	SELECT Base.CLAIM_FACT_KEY, Base.SORT_ORDER, Base.[OCCURRENCE_DATE] FROM CTE_Base AS Base ) AS ImportantColumns
PIVOT( 
	MAX( [OCCURRENCE_DATE] )
	FOR SORT_ORDER IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12] )
	) AS PivotCodes
),

/**************************************************************************************************************/
/* PIVOT THE BASE INFORMATION TO GET DENORMALIZED OCCURRENCE DESCRIPTIONS */

CTE_OCCURRENCE_DESCRIPTION AS (

SELECT
 CLAIM_FACT_KEY
,[Claim Occurrence Description 1] =
	[1]
,[Claim Occurrence Description 2] =
	[2]
,[Claim Occurrence Description 3] =
	[3]
,[Claim Occurrence Description 4] =
	[4]
,[Claim Occurrence Description 5] =
	[5]
,[Claim Occurrence Description 6] =
	[6]
,[Claim Occurrence Description 7] =
	[7]
,[Claim Occurrence Description 8] =
	[8]
,[Claim Occurrence Description 9] =
	[9]
,[Claim Occurrence Description 10] =
	[10]
,[Claim Occurrence Description 11] =
	[11]
,[Claim Occurrence Description 12] =
	[12]
FROM (
	SELECT Base.CLAIM_FACT_KEY, Base.SORT_ORDER, Base.OCCURRENCE_DESCRIPTION FROM CTE_Base AS Base ) AS ImportantColumns
PIVOT( 
	MAX( OCCURRENCE_DESCRIPTION )
	FOR SORT_ORDER IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12] )
	) AS PivotCodes
)

/**************************************************************************************************************/
/* COMBINE THE PIVOTS TO FULLY DENORMALIZE THE CLAIM OCCURRENCES */

SELECT
 CTE_OCCURRENCE_CODES.CLAIM_FACT_KEY
,CTE_OCCURRENCE_CODES.[Claim Occurrence Code 1]
,CTE_OCCURRENCE_DESCRIPTION.[Claim Occurrence Description 1]
,CTE_OCCURRENCE_DATES.[Claim Occurrence Date 1]

,CTE_OCCURRENCE_CODES.[Claim Occurrence Code 2]
,CTE_OCCURRENCE_DESCRIPTION.[Claim Occurrence Description 2]
,CTE_OCCURRENCE_DATES.[Claim Occurrence Date 2]

,CTE_OCCURRENCE_CODES.[Claim Occurrence Code 3]
,CTE_OCCURRENCE_DESCRIPTION.[Claim Occurrence Description 3]
,CTE_OCCURRENCE_DATES.[Claim Occurrence Date 3]

,CTE_OCCURRENCE_CODES.[Claim Occurrence Code 4]
,CTE_OCCURRENCE_DESCRIPTION.[Claim Occurrence Description 4]
,CTE_OCCURRENCE_DATES.[Claim Occurrence Date 4]

,CTE_OCCURRENCE_CODES.[Claim Occurrence Code 5]
,CTE_OCCURRENCE_DESCRIPTION.[Claim Occurrence Description 5]
,CTE_OCCURRENCE_DATES.[Claim Occurrence Date 5]

,CTE_OCCURRENCE_CODES.[Claim Occurrence Code 6]
,CTE_OCCURRENCE_DESCRIPTION.[Claim Occurrence Description 6]
,CTE_OCCURRENCE_DATES.[Claim Occurrence Date 6]

,CTE_OCCURRENCE_CODES.[Claim Occurrence Code 7]
,CTE_OCCURRENCE_DESCRIPTION.[Claim Occurrence Description 7]
,CTE_OCCURRENCE_DATES.[Claim Occurrence Date 7]

,CTE_OCCURRENCE_CODES.[Claim Occurrence Code 8]
,CTE_OCCURRENCE_DESCRIPTION.[Claim Occurrence Description 8]
,CTE_OCCURRENCE_DATES.[Claim Occurrence Date 8]

,CTE_OCCURRENCE_CODES.[Claim Occurrence Code 9]
,CTE_OCCURRENCE_DESCRIPTION.[Claim Occurrence Description 9]
,CTE_OCCURRENCE_DATES.[Claim Occurrence Date 9]

,CTE_OCCURRENCE_CODES.[Claim Occurrence Code 10]
,CTE_OCCURRENCE_DESCRIPTION.[Claim Occurrence Description 10]
,CTE_OCCURRENCE_DATES.[Claim Occurrence Date 10]

,CTE_OCCURRENCE_CODES.[Claim Occurrence Code 11]
,CTE_OCCURRENCE_DESCRIPTION.[Claim Occurrence Description 11]
,CTE_OCCURRENCE_DATES.[Claim Occurrence Date 11]

,CTE_OCCURRENCE_CODES.[Claim Occurrence Code 12]
,CTE_OCCURRENCE_DESCRIPTION.[Claim Occurrence Description 12]
,CTE_OCCURRENCE_DATES.[Claim Occurrence Date 12]

FROM
CTE_OCCURRENCE_CODES

	JOIN CTE_OCCURRENCE_DATES
		ON CTE_OCCURRENCE_DATES.CLAIM_FACT_KEY = CTE_OCCURRENCE_CODES.CLAIM_FACT_KEY
		
	JOIN CTE_OCCURRENCE_DESCRIPTION
		ON CTE_OCCURRENCE_DESCRIPTION.CLAIM_FACT_KEY = CTE_OCCURRENCE_CODES.CLAIM_FACT_KEY

;
GO
