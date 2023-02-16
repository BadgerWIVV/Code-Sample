USE [HCI]
GO

/****** Object:  View [DN].[CLAIM_DIAGNOSES]    Script Date: 9/1/2020 2:24:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**************************************************************************************************************/
/* CREATE THE VIEW */

CREATE VIEW [DN].[wea_prod_dw_REASON_FOR_VISIT_CLAIM_DIAGNOSES]  AS 

/**************************************************************************************************************/
/* IDENTIFY THE MAXIMUM NUMBER OF OPTIONS AVAILABLE*/

/* FOR DEBUGGING */ --SELECT MAX( [SORT_ORDER] ) FROM wea_prod_dw.dbo.CLAIM_FACT_TO_DIAGNOSIS WHERE CLAIM_DIAGNOSIS_TYPE = 'e'

/**************************************************************************************************************/
/* ACQUIRE THE BASE CLAIM DIAGNOSIS INFORMATION TO PIVOT */

WITH CTE_Base_UnRanked AS (

SELECT
 Claim2Diagnosis.CLAIM_FACT_KEY
,Claim2Diagnosis.SORT_ORDER
,Diagnosis.DIAGNOSIS_CODE
,Diagnosis.STANDARDIZED_DIAGNOSIS_CODE
,Diagnosis.DIAGNOSIS_SHORT_DESC
,Diagnosis.DIAGNOSIS_TYPE_NAME
FROM
wea_prod_dw.dbo.CLAIM_FACT_TO_DIAGNOSIS AS Claim2Diagnosis

		JOIN wea_prod_dw.dbo.DIAGNOSIS AS Diagnosis
			ON Diagnosis.DIAGNOSIS_CODE = Claim2Diagnosis.DIAGNOSIS_CODE

WHERE
Claim2Diagnosis.CLAIM_DIAGNOSIS_TYPE = 'r'
GROUP BY
 Claim2Diagnosis.CLAIM_FACT_KEY
,Claim2Diagnosis.SORT_ORDER
,Diagnosis.DIAGNOSIS_CODE
,Diagnosis.STANDARDIZED_DIAGNOSIS_CODE
,Diagnosis.DIAGNOSIS_SHORT_DESC
,Diagnosis.DIAGNOSIS_TYPE_NAME
),

/**************************************************************************************************************/
/* Rank the Sort_Order as they don't progress ordinally across integers beginning at 1 */

CTE_Base AS (

SELECT
 CLAIM_FACT_KEY
,SORT_ORDER =
	ROW_NUMBER() OVER( PARTITION BY CLAIM_FACT_KEY ORDER BY SORT_ORDER )
,DIAGNOSIS_CODE
,STANDARDIZED_DIAGNOSIS_CODE
,DIAGNOSIS_SHORT_DESC
,DIAGNOSIS_TYPE_NAME
FROM
CTE_Base_UnRanked

),

/**************************************************************************************************************/
/* PIVOT THE BASE INFORMATION TO GET DENORMALIZED CODES */

CTE_Codes AS (

SELECT
 CLAIM_FACT_KEY
,[Claim Diagnosis 1] =
	[1]
,[Claim Diagnosis 2] =
	[2]
,[Claim Diagnosis 3] =
	[3]
,[Claim Diagnosis 4] =
	[4]
,[Claim Diagnosis 5] =
	[5]
,[Claim Diagnosis 6] =
	[6]
,[Claim Diagnosis 7] =
	[7]
,[Claim Diagnosis 8] =
	[8]
,[Claim Diagnosis 9] =
	[9]
,[Claim Diagnosis 10] =
	[10]
,[Claim Diagnosis 11] =
	[11]
,[Claim Diagnosis 12] =
	[12]
,[Claim Diagnosis 13] =
	[13]
,[Claim Diagnosis 14] =
	[14]
,[Claim Diagnosis 15] =
	[15]
,[Claim Diagnosis 16] =
	[16]
,[Claim Diagnosis 17] =
	[17]
,[Claim Diagnosis 18] =
	[18]
,[Claim Diagnosis 19] =
	[19]
,[Claim Diagnosis 20] =
	[20]
,[Claim Diagnosis 21] =
	[21]
,[Claim Diagnosis 22] =
	[22]
,[Claim Diagnosis 23] =
	[23]
,[Claim Diagnosis 24] =
	[24]
,[Claim Diagnosis 25] =
	[25]
,[Claim Diagnosis 26] =
	[26]
,[Claim Diagnosis 27] =
	[27]
,[Claim Diagnosis 28] =
	[28]
,[Claim Diagnosis 29] =
	[29]
,[Claim Diagnosis 30] =
	[30]
FROM (
	SELECT Base.CLAIM_FACT_KEY, Base.SORT_ORDER, Base.DIAGNOSIS_CODE FROM CTE_Base AS Base ) AS ImportantColumns
PIVOT( 
	MAX( DIAGNOSIS_CODE )
	FOR SORT_ORDER IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30] )
	) AS PivotCodes
),

/**************************************************************************************************************/
/* PIVOT THE BASE INFORMATION TO GET DENORMALIZED STANDARD CODES */

CTE_Standard_Codes AS (

SELECT
 CLAIM_FACT_KEY
,[Claim Standard Diagnosis Code 1] =
	[1]
,[Claim Standard Diagnosis Code 2] =
	[2]
,[Claim Standard Diagnosis Code 3] =
	[3]
,[Claim Standard Diagnosis Code 4] =
	[4]
,[Claim Standard Diagnosis Code 5] =
	[5]
,[Claim Standard Diagnosis Code 6] =
	[6]
,[Claim Standard Diagnosis Code 7] =
	[7]
,[Claim Standard Diagnosis Code 8] =
	[8]
,[Claim Standard Diagnosis Code 9] =
	[9]
,[Claim Standard Diagnosis Code 10] =
	[10]
,[Claim Standard Diagnosis Code 11] =
	[11]
,[Claim Standard Diagnosis Code 12] =
	[12]
,[Claim Standard Diagnosis Code 13] =
	[13]
,[Claim Standard Diagnosis Code 14] =
	[14]
,[Claim Standard Diagnosis Code 15] =
	[15]
,[Claim Standard Diagnosis Code 16] =
	[16]
,[Claim Standard Diagnosis Code 17] =
	[17]
,[Claim Standard Diagnosis Code 18] =
	[18]
,[Claim Standard Diagnosis Code 19] =
	[19]
,[Claim Standard Diagnosis Code 20] =
	[20]
,[Claim Standard Diagnosis Code 21] =
	[21]
,[Claim Standard Diagnosis Code 22] =
	[22]
,[Claim Standard Diagnosis Code 23] =
	[23]
,[Claim Standard Diagnosis Code 24] =
	[24]
,[Claim Standard Diagnosis Code 25] =
	[25]
,[Claim Standard Diagnosis Code 26] =
	[26]
,[Claim Standard Diagnosis Code 27] =
	[27]
,[Claim Standard Diagnosis Code 28] =
	[28]
,[Claim Standard Diagnosis Code 29] =
	[29]
,[Claim Standard Diagnosis Code 30] =
	[30]
FROM (
	SELECT Base.CLAIM_FACT_KEY, Base.SORT_ORDER, Base.STANDARDIZED_DIAGNOSIS_CODE FROM CTE_Base AS Base ) AS ImportantColumns
PIVOT( 
	MAX( STANDARDIZED_DIAGNOSIS_CODE )
	FOR SORT_ORDER IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30] )
	) AS PivotCodes
),

/**************************************************************************************************************/
/* PIVOT THE BASE INFORMATION TO GET DENORMALIZED DESCRIPTION NAMES */

CTE_Descriptions AS (

SELECT
 CLAIM_FACT_KEY
,[Claim Diagnosis Description 1] =
	[1]
,[Claim Diagnosis Description 2] =
	[2]
,[Claim Diagnosis Description 3] =
	[3]
,[Claim Diagnosis Description 4] =
	[4]
,[Claim Diagnosis Description 5] =
	[5]
,[Claim Diagnosis Description 6] =
	[6]
,[Claim Diagnosis Description 7] =
	[7]
,[Claim Diagnosis Description 8] =
	[8]
,[Claim Diagnosis Description 9] =
	[9]
,[Claim Diagnosis Description 10] =
	[10]
,[Claim Diagnosis Description 11] =
	[11]
,[Claim Diagnosis Description 12] =
	[12]
,[Claim Diagnosis Description 13] =
	[13]
,[Claim Diagnosis Description 14] =
	[14]
,[Claim Diagnosis Description 15] =
	[15]
,[Claim Diagnosis Description 16] =
	[16]
,[Claim Diagnosis Description 17] =
	[17]
,[Claim Diagnosis Description 18] =
	[18]
,[Claim Diagnosis Description 19] =
	[19]
,[Claim Diagnosis Description 20] =
	[20]
,[Claim Diagnosis Description 21] =
	[21]
,[Claim Diagnosis Description 22] =
	[22]
,[Claim Diagnosis Description 23] =
	[23]
,[Claim Diagnosis Description 24] =
	[24]
,[Claim Diagnosis Description 25] =
	[25]
,[Claim Diagnosis Description 26] =
	[26]
,[Claim Diagnosis Description 27] =
	[27]
,[Claim Diagnosis Description 28] =
	[28]
,[Claim Diagnosis Description 29] =
	[29]
,[Claim Diagnosis Description 30] =
	[30]
FROM (
	SELECT Base.CLAIM_FACT_KEY, Base.SORT_ORDER, Base.DIAGNOSIS_SHORT_DESC FROM CTE_Base AS Base) AS ImportantColumns
PIVOT( 
	MAX( DIAGNOSIS_SHORT_DESC )
	FOR SORT_ORDER IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30] )
	) AS PivotCodes
),


/**************************************************************************************************************/
/* PIVOT THE BASE INFORMATION TO GET DENORMALIZED CLAIM DIAGNOSES TYPES */

CTE_Type AS (

SELECT
 CLAIM_FACT_KEY
,[Claim Diagnosis Type 1] =
	[1]
,[Claim Diagnosis Type 2] =
	[2]
,[Claim Diagnosis Type 3] =
	[3]
,[Claim Diagnosis Type 4] =
	[4]
,[Claim Diagnosis Type 5] =
	[5]
,[Claim Diagnosis Type 6] =
	[6]
,[Claim Diagnosis Type 7] =
	[7]
,[Claim Diagnosis Type 8] =
	[8]
,[Claim Diagnosis Type 9] =
	[9]
,[Claim Diagnosis Type 10] =
	[10]
,[Claim Diagnosis Type 11] =
	[11]
,[Claim Diagnosis Type 12] =
	[12]
,[Claim Diagnosis Type 13] =
	[13]
,[Claim Diagnosis Type 14] =
	[14]
,[Claim Diagnosis Type 15] =
	[15]
,[Claim Diagnosis Type 16] =
	[16]
,[Claim Diagnosis Type 17] =
	[17]
,[Claim Diagnosis Type 18] =
	[18]
,[Claim Diagnosis Type 19] =
	[19]
,[Claim Diagnosis Type 20] =
	[20]
,[Claim Diagnosis Type 21] =
	[21]
,[Claim Diagnosis Type 22] =
	[22]
,[Claim Diagnosis Type 23] =
	[23]
,[Claim Diagnosis Type 24] =
	[24]
,[Claim Diagnosis Type 25] =
	[25]
,[Claim Diagnosis Type 26] =
	[26]
,[Claim Diagnosis Type 27] =
	[27]
,[Claim Diagnosis Type 28] =
	[28]
,[Claim Diagnosis Type 29] =
	[29]
,[Claim Diagnosis Type 30] =
	[30]
FROM (
	SELECT Base.CLAIM_FACT_KEY, Base.SORT_ORDER, Base.DIAGNOSIS_TYPE_NAME FROM CTE_Base AS Base) AS ImportantColumns
PIVOT( 
	MAX( DIAGNOSIS_TYPE_NAME )
	FOR SORT_ORDER IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30] )
	) AS PivotCodes
)

/**************************************************************************************************************/
/* COMBINE THE PIVOTS TO FULLY DENORMALIZE THE CLAIM DIAGNOSES */

SELECT
 Codes.CLAIM_FACT_KEY
,Codes.[Claim Diagnosis 1]
,StandardCodes.[Claim Standard Diagnosis Code 1]
,Descriptions.[Claim Diagnosis Description 1]
,DxType.[Claim Diagnosis Type 1]
,Codes.[Claim Diagnosis 2]
,StandardCodes.[Claim Standard Diagnosis Code 2]
,Descriptions.[Claim Diagnosis Description 2]
,DxType.[Claim Diagnosis Type 2]
,Codes.[Claim Diagnosis 3]
,StandardCodes.[Claim Standard Diagnosis Code 3]
,Descriptions.[Claim Diagnosis Description 3]
,DxType.[Claim Diagnosis Type 3]
,Codes.[Claim Diagnosis 4]
,StandardCodes.[Claim Standard Diagnosis Code 4]
,Descriptions.[Claim Diagnosis Description 4]
,DxType.[Claim Diagnosis Type 4]
,Codes.[Claim Diagnosis 5]
,StandardCodes.[Claim Standard Diagnosis Code 5]
,Descriptions.[Claim Diagnosis Description 5]
,DxType.[Claim Diagnosis Type 5]
,Codes.[Claim Diagnosis 6]
,StandardCodes.[Claim Standard Diagnosis Code 6]
,Descriptions.[Claim Diagnosis Description 6]
,DxType.[Claim Diagnosis Type 6]
,Codes.[Claim Diagnosis 7]
,StandardCodes.[Claim Standard Diagnosis Code 7]
,Descriptions.[Claim Diagnosis Description 7]
,DxType.[Claim Diagnosis Type 7]
,Codes.[Claim Diagnosis 8]
,StandardCodes.[Claim Standard Diagnosis Code 8]
,Descriptions.[Claim Diagnosis Description 8]
,DxType.[Claim Diagnosis Type 8]
,Codes.[Claim Diagnosis 9]
,StandardCodes.[Claim Standard Diagnosis Code 9]
,Descriptions.[Claim Diagnosis Description 9]
,DxType.[Claim Diagnosis Type 9]
,Codes.[Claim Diagnosis 10]
,StandardCodes.[Claim Standard Diagnosis Code 10]
,Descriptions.[Claim Diagnosis Description 10]
,DxType.[Claim Diagnosis Type 10]
,Codes.[Claim Diagnosis 11]
,StandardCodes.[Claim Standard Diagnosis Code 11]
,Descriptions.[Claim Diagnosis Description 11]
,DxType.[Claim Diagnosis Type 11]
,Codes.[Claim Diagnosis 12]
,StandardCodes.[Claim Standard Diagnosis Code 12]
,Descriptions.[Claim Diagnosis Description 12]
,DxType.[Claim Diagnosis Type 12]
,Codes.[Claim Diagnosis 13]
,StandardCodes.[Claim Standard Diagnosis Code 13]
,Descriptions.[Claim Diagnosis Description 13]
,DxType.[Claim Diagnosis Type 13]
,Codes.[Claim Diagnosis 14]
,StandardCodes.[Claim Standard Diagnosis Code 14]
,Descriptions.[Claim Diagnosis Description 14]
,DxType.[Claim Diagnosis Type 14]
,Codes.[Claim Diagnosis 15]
,StandardCodes.[Claim Standard Diagnosis Code 15]
,Descriptions.[Claim Diagnosis Description 15]
,DxType.[Claim Diagnosis Type 15]
,Codes.[Claim Diagnosis 16]
,StandardCodes.[Claim Standard Diagnosis Code 16]
,Descriptions.[Claim Diagnosis Description 16]
,DxType.[Claim Diagnosis Type 16]
,Codes.[Claim Diagnosis 17]
,StandardCodes.[Claim Standard Diagnosis Code 17]
,Descriptions.[Claim Diagnosis Description 17]
,DxType.[Claim Diagnosis Type 17]
,Codes.[Claim Diagnosis 18]
,StandardCodes.[Claim Standard Diagnosis Code 18]
,Descriptions.[Claim Diagnosis Description 18]
,DxType.[Claim Diagnosis Type 18]
,Codes.[Claim Diagnosis 19]
,StandardCodes.[Claim Standard Diagnosis Code 19]
,Descriptions.[Claim Diagnosis Description 19]
,DxType.[Claim Diagnosis Type 19]
,Codes.[Claim Diagnosis 20]
,StandardCodes.[Claim Standard Diagnosis Code 20]
,Descriptions.[Claim Diagnosis Description 20]
,DxType.[Claim Diagnosis Type 20]
,Codes.[Claim Diagnosis 21]
,StandardCodes.[Claim Standard Diagnosis Code 21]
,Descriptions.[Claim Diagnosis Description 21]
,DxType.[Claim Diagnosis Type 21]
,Codes.[Claim Diagnosis 22]
,StandardCodes.[Claim Standard Diagnosis Code 22]
,Descriptions.[Claim Diagnosis Description 22]
,DxType.[Claim Diagnosis Type 22]
,Codes.[Claim Diagnosis 23]
,StandardCodes.[Claim Standard Diagnosis Code 23]
,Descriptions.[Claim Diagnosis Description 23]
,DxType.[Claim Diagnosis Type 23]
,Codes.[Claim Diagnosis 24]
,StandardCodes.[Claim Standard Diagnosis Code 24]
,Descriptions.[Claim Diagnosis Description 24]
,DxType.[Claim Diagnosis Type 24]
,Codes.[Claim Diagnosis 25]
,StandardCodes.[Claim Standard Diagnosis Code 25]
,Descriptions.[Claim Diagnosis Description 25]
,DxType.[Claim Diagnosis Type 25]
,Codes.[Claim Diagnosis 26]
,StandardCodes.[Claim Standard Diagnosis Code 26]
,Descriptions.[Claim Diagnosis Description 26]
,DxType.[Claim Diagnosis Type 26]
,Codes.[Claim Diagnosis 27]
,StandardCodes.[Claim Standard Diagnosis Code 27]
,Descriptions.[Claim Diagnosis Description 27]
,DxType.[Claim Diagnosis Type 27]
,Codes.[Claim Diagnosis 28]
,StandardCodes.[Claim Standard Diagnosis Code 28]
,Descriptions.[Claim Diagnosis Description 28]
,DxType.[Claim Diagnosis Type 28]
,Codes.[Claim Diagnosis 29]
,StandardCodes.[Claim Standard Diagnosis Code 29]
,Descriptions.[Claim Diagnosis Description 29]
,DxType.[Claim Diagnosis Type 29]
,Codes.[Claim Diagnosis 30]
,StandardCodes.[Claim Standard Diagnosis Code 30]
,Descriptions.[Claim Diagnosis Description 30]
,DxType.[Claim Diagnosis Type 30]
FROM
CTE_Codes AS Codes

	JOIN CTE_Descriptions AS Descriptions
		ON Descriptions.CLAIM_FACT_KEY = Codes.CLAIM_FACT_KEY
		
	JOIN CTE_Standard_Codes AS StandardCodes
		ON StandardCodes.CLAIM_FACT_KEY = Codes.CLAIM_FACT_KEY
		
	JOIN CTE_Type AS DxType
		ON DxType.CLAIM_FACT_KEY = Codes.CLAIM_FACT_KEY;
GO


