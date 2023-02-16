/**************************************************************************************************************/
/* ACQUIRE THE BASE MODIFIER INFORMATION TO PIVOT */

WITH #Base AS (

SELECT
 ClaimLine2Modifier.CLAIM_LINE_FACT_KEY
,ClaimLine2Modifier.SORT_ORDER
,Modifier.MODIFIER_CODE
,Modifier.MODIFIER_NAME
FROM
WEA_EDW.FACT.CLAIM_LINE_MODIFIER_MAPPING_FACT AS ClaimLine2Modifier


		JOIN WEA_EDW.DIM.MODIFIER_DIM AS Modifier
			ON Modifier.MODIFIER_DIM_KEY = ClaimLine2Modifier.MODIFIER_DIM_KEY
)

/**************************************************************************************************************/
/* PIVOT THE BASE INFORMATION TO GET DENORMALIZED CODES */


SELECT TOP 100
 CLAIM_LINE_FACT_KEY
,[Modifier 1] =
	[1] /* Mimics hard coded values */
,[Modifier 2] =
	[2]
,[Modifier 3] =
	[3]
,[Modifier 4] =
	[4]
FROM (
	SELECT Base.CLAIM_LINE_FACT_KEY, Base.SORT_ORDER, Base.MODIFIER_CODE FROM #Base AS Base ) AS ImportantColumns /* Choose only the necessary columns: key, aggregate, pivot */
PIVOT( 
	MAX( MODIFIER_CODE ) /* declare the aggregate of choice */
	FOR SORT_ORDER IN ( [1], [2], [3], [4] ) /* Hard code values of pivot field in brackets */
	) AS PivotCodes
WHERE
[4] IS NOT NULL
