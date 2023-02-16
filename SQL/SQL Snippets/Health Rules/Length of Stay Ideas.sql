IF OBJECT_ID( 'TEMPDB.DBO.#LOS' ) IS NOT NULL DROP TABLE #LOS

SELECT DISTINCT
 CF.CLAIM_HCC_ID
,CF.CLAIM_STATUS
,[Admit Date] =
	AdmitDate.DATE_VALUE
,[Discharge Date] =
	DischargeDate.DATE_VALUE
,[Statement Start Date] =
		StatementStartDate.DATE_VALUE
,[Statement End Date] =
		StatementEndDate.DATE_VALUE
,[LOS] =
	DATEDIFF( DAY, ISNULL( AdmitDate.DATE_VALUE, StatementStartDate.DATE_VALUE ), ISNULL( DischargeDate.DATE_VALUE ,StatementEndDate.DATE_VALUE ) ) 
,[LOS Adjusted by 1] =
	DATEDIFF( DAY, ISNULL( AdmitDate.DATE_VALUE, StatementStartDate.DATE_VALUE ), ISNULL( DischargeDate.DATE_VALUE ,StatementEndDate.DATE_VALUE ) )  + 1
,CF.TYPE_OF_BILL_CODE
INTO
#LOS
FROM
wea_prod_dw.dbo.claim_fact AS CF

	LEFT JOIN wea_prod_dw.dbo.type_of_bill AS TOB
		ON TOB.TYPE_OF_BILL_CODE = CF.TYPE_OF_BILL_CODE

	LEFT JOIN wea_prod_dw.dbo.date_dimension AS AdmitDate
		ON AdmitDate.DATE_KEY = CF.ADMISSION_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.date_dimension AS DischargeDate
		ON DischargeDate.DATE_KEY = CF.DISCHARGE_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.date_dimension AS StatementEndDate
		ON StatementEndDate.DATE_KEY = CF.STATEMENT_END_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.date_dimension AS StatementStartDate
		ON StatementStartDate.DATE_KEY = CF.STATEMENT_START_DATE_KEY
WHERE
TOB.ADMIT_STATUS_CODE = 'I'
AND
CF.IS_CURRENT = 'Y'


SELECT * FROM #LOS WHERE CLAIM_HCC_ID = ''

/*******************************************************************************************************************/

IF OBJECT_ID( 'TEMPDB.DBO.#LastClaimLOS' ) IS NOT NULL DROP TABLE #LastClaimLOS

SELECT DISTINCT
 CF.CLAIM_HCC_ID
,CF.CLAIM_STATUS
,[Admit Date] =
	AdmitDate.DATE_VALUE
,[Discharge Date] =
	DischargeDate.DATE_VALUE
,[Statement Start Date] =
		StatementStartDate.DATE_VALUE
,[Statement End Date] =
		StatementEndDate.DATE_VALUE
,[LOS] =
	DATEDIFF( DAY, ISNULL( AdmitDate.DATE_VALUE, StatementStartDate.DATE_VALUE ), ISNULL( DischargeDate.DATE_VALUE ,StatementEndDate.DATE_VALUE ) ) 
,[LOS Adjusted by 1] =
	DATEDIFF( DAY, ISNULL( AdmitDate.DATE_VALUE, StatementStartDate.DATE_VALUE ), ISNULL( DischargeDate.DATE_VALUE ,StatementEndDate.DATE_VALUE ) )  + 1
INTO
#LastClaimLOS
FROM
wea_prod_dw.dbo.claim_fact AS CF

	LEFT JOIN wea_prod_dw.dbo.type_of_bill AS TOB
		ON TOB.TYPE_OF_BILL_CODE = CF.TYPE_OF_BILL_CODE

	LEFT JOIN wea_prod_dw.dbo.date_dimension AS AdmitDate
		ON AdmitDate.DATE_KEY = CF.ADMISSION_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.date_dimension AS DischargeDate
		ON DischargeDate.DATE_KEY = CF.DISCHARGE_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.date_dimension AS StatementEndDate
		ON StatementEndDate.DATE_KEY = CF.STATEMENT_END_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.date_dimension AS StatementStartDate
		ON StatementStartDate.DATE_KEY = CF.STATEMENT_START_DATE_KEY
WHERE
TOB.ADMIT_STATUS_CODE = 'I'
AND
CF.IS_CURRENT = 'Y'
AND
/* https://cheatography.com/deleted-2754/cheat-sheets/ub-04-claim-type-of-bill-codes/ */
LEFT( REVERSE( TOB.TYPE_OF_BILL_CODE ), 1 ) IN ( 
 '1' /* Admit Through Discharge */
,'4' /* Interim - Last Claim (Not valid for PPS Bills) */
,'9' /* Final claim for a Home Health PPS Episode */
)

SELECT * FROM #LastClaimLOS WHERE CLAIM_HCC_ID = ''

/*******************************************************************************************************************/

IF OBJECT_ID( 'TEMPDB.DBO.#HealthRulesLOS' ) IS NOT NULL DROP TABLE #HealthRulesLOS

SELECT
 CF.CLAIM_HCC_ID
,CF.CLAIM_STATUS
,[Health Rules LOS] =
	SUM( CF.LENGTH_OF_STAY )
INTO
#HealthRulesLOS
FROM
wea_prod_dw.dbo.CLAIM_FACT AS CF
WHERE
CF.IS_CURRENT = 'Y'
AND
CF.LENGTH_OF_STAY > 0
GROUP BY
 CF.CLAIM_HCC_ID
,CF.CLAIM_STATUS

/*******************************************************************************************************************/

IF OBJECT_ID( 'TEMPDB.DBO.#EriksLOS' ) IS NOT NULL DROP TABLE #EriksLOS

SELECT
 CF.CLAIM_HCC_ID
,CF.CLAIM_STATUS
,[Erik's LOS] =
	sum(case when CLF.REVENUE_CODE between '0100' and '0209' then DATEDIFF( DAY ,ServiceStartDate.DATE_VALUE,ServiceEndDate.DATE_VALUE) else 0 end)+1 

INTO
#EriksLOS
FROM
wea_prod_dw.dbo.claim_fact AS CF

	LEFT JOIN wea_prod_dw.dbo.type_of_bill AS TOB
		ON TOB.TYPE_OF_BILL_CODE = CF.TYPE_OF_BILL_CODE

	LEFT JOIN wea_prod_dw.dbo.date_dimension AS AdmitDate
		ON AdmitDate.DATE_KEY = CF.ADMISSION_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.date_dimension AS DischargeDate
		ON DischargeDate.DATE_KEY = CF.DISCHARGE_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.date_dimension AS StatementEndDate
		ON StatementEndDate.DATE_KEY = CF.STATEMENT_END_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.date_dimension AS StatementStartDate
		ON StatementStartDate.DATE_KEY = CF.STATEMENT_START_DATE_KEY

	JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
		ON	CLF.CLAIM_FACT_KEY = CF.CLAIM_FACT_KEY

		LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS ServiceStartDate
			ON	ServiceStartDate.DATE_KEY = CLF.SERVICE_START_DATE_KEY

		LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS ServiceEndDate
			ON	ServiceEndDate.DATE_KEY = CLF.SERVICE_END_DATE_KEY

WHERE
TOB.ADMIT_STATUS_CODE = 'I'
AND
CF.IS_CURRENT = 'Y'
AND
CLF.CLAIM_LINE_STATUS_CODE = 'a'
AND
CF.CLAIM_STATUS = 'Final'
GROUP BY
 CF.CLAIM_HCC_ID
,CF.CLAIM_STATUS


--SELECT * FROM #EriksLOS WHERE CLAIM_HCC_ID = ''

/*******************************************************************************************************************/

IF OBJECT_ID( 'TEMPDB.DBO.#RandB' ) IS NOT NULL DROP TABLE #RandB;

SELECT
 CF.CLAIM_HCC_ID
,CF.CLAIM_STATUS
,[LOS] =
	SUM( CLF.UNIT_COUNT )
INTO
#RandB
FROM
[wea_prod_dw].[dbo].[CLAIM_LINE_FACT] AS CLF
	
	LEFT JOIN wea_prod_dw.dbo.CLAIM_FACT AS CF
		ON CF.CLAIM_FACT_KEY = CLF.CLAIM_FACT_KEY
			
WHERE
CLF.IS_ROOM_AND_BOARD  = 'Y'
AND
CF.IS_CURRENT = 'Y'
GROUP BY
 CF.CLAIM_HCC_ID
,CF.CLAIM_STATUS

/*******************************************************************************************************************/

IF OBJECT_ID( 'TEMPDB.DBO.#RandBAdjudicated' ) IS NOT NULL DROP TABLE #RandBAdjudicated;

SELECT
 CF.CLAIM_HCC_ID
,CF.CLAIM_STATUS
,[LOS] =
	SUM( CLF.UNIT_COUNT ) 
INTO
#RandBAdjudicated
FROM
[wea_prod_dw].[dbo].[CLAIM_LINE_FACT] AS CLF
	
	LEFT JOIN wea_prod_dw.dbo.CLAIM_FACT AS CF
		ON CF.CLAIM_FACT_KEY = CLF.CLAIM_FACT_KEY
			
WHERE
CLF.IS_ROOM_AND_BOARD  = 'Y'
AND
CF.IS_CURRENT = 'Y'
AND
CLF.CLAIM_LINE_STATUS_CODE = 'a'
GROUP BY
CF.CLAIM_HCC_ID
,CF.CLAIM_STATUS

/*******************************************************************************************************************/

IF OBJECT_ID( 'TEMPDB.DBO.#Medinsight' ) IS NOT NULL DROP TABLE #Medinsight;

SELECT
 V.CLAIM_ID
,CLAIM_STATUS
,[LOS] =
	SUM( V.MR_UNITS_DAYS_RAW )
INTO
#Medinsight
FROM
MedInsight.MedInsight.usr.VW_CLAIM AS V
	
	--LEFT JOIN [wea_dw].[DMLIB].[CLM_KEY] AS ClaimKeys
	--	ON ClaimKeys.WKSHT = V.CLAIM_ID
WHERE
V.HCG_SETTING = '1. Facility Inpatient'
GROUP BY
 V.CLAIM_ID
,CLAIM_STATUS
HAVING
SUM( V.MR_UNITS_DAYS_RAW ) > 0

--SELECT  * FROM #Medinsight WHERE CLAIM_ID =  ''

/*******************************************************************************************************************/

SELECT TOP 1000
 LOS.CLAIM_HCC_ID
,LOS.CLAIM_STATUS
,LOS.LOS
,LOS.[LOS Adjusted by 1]
,[Room and Board Units] =
	RandB.LOS
,[Room and Board Adjudicated Units] =
	RandBAdjudicated.LOS
,[MedInsight LOS] =
	MedInsight.LOS
,#EriksLOS.[Erik's LOS]
,#HealthRulesLOS.[Health Rules LOS] 
,[Last Claim LOS] =
	#LastClaimLOS.LOS
FROM
#LOS AS LOS
	
	LEFT JOIN #RandB AS RandB
		ON RandB.CLAIM_HCC_ID = LOS.CLAIM_HCC_ID

	LEFT JOIN #RandBAdjudicated AS RandBAdjudicated
		ON RandBAdjudicated.CLAIM_HCC_ID = LOS.CLAIM_HCC_ID

	LEFT JOIN #Medinsight AS MedInsight
		ON MedInsight.CLAIM_ID = LOS.CLAIM_HCC_ID

	LEFT JOIN #EriksLOS
		ON #EriksLOS.CLAIM_HCC_ID = LOS.CLAIM_HCC_ID

	LEFT JOIN #HealthRulesLOS
		ON #HealthRulesLOS.CLAIM_HCC_ID = LOS.CLAIM_HCC_ID

	LEFT JOIN #LastClaimLOS
		ON	#LastClaimLOS.CLAIM_HCC_ID = LOS.CLAIM_HCC_ID

WHERE
LOS.CLAIM_STATUS = 'Final'
AND
LOS.[Statement End Date] BETWEEN DATEADD( DAY, 1, DATEADD( MONTH, -61, GETDATE() ) ) AND EOMONTH( DATEADD( MONTH, -1, GETDATE() ) )
ORDER BY
LOS.CLAIM_HCC_ID DESC

/*******************************************************************************************************************/

SELECT
 [LOS] =
	SUM( LOS.LOS )
,[LOS Adjusted by 1] =
	SUM( LOS.[LOS Adjusted by 1] )
,[Room and Board Units] =
	SUM( RandB.LOS )
,[Room and Board Adjudicated Units] =
	SUM( RandBAdjudicated.LOS )
,[MedInsight LOS] =
	SUM( MedInsight.LOS )
,[Erik's LOS] =
	SUM( #EriksLOS.[Erik's LOS] )
,[Health Rules LOS] =
	SUM( #HealthRulesLOS.[Health Rules LOS]  )
,[Last Claim LOS] =
	SUM( #LastClaimLOS.LOS )
FROM
#LOS AS LOS
	
	LEFT JOIN #RandB AS RandB
		ON RandB.CLAIM_HCC_ID = LOS.CLAIM_HCC_ID

	LEFT JOIN #RandBAdjudicated AS RandBAdjudicated
		ON RandBAdjudicated.CLAIM_HCC_ID = LOS.CLAIM_HCC_ID

	LEFT JOIN #Medinsight AS MedInsight
		ON MedInsight.CLAIM_ID = LOS.CLAIM_HCC_ID

	LEFT JOIN #EriksLOS
		ON #EriksLOS.CLAIM_HCC_ID = LOS.CLAIM_HCC_ID

	LEFT JOIN #HealthRulesLOS
		ON #HealthRulesLOS.CLAIM_HCC_ID = LOS.CLAIM_HCC_ID

	LEFT JOIN #LastClaimLOS
		ON	#LastClaimLOS.CLAIM_HCC_ID = LOS.CLAIM_HCC_ID

WHERE
LOS.CLAIM_STATUS = 'Final'
AND
LOS.[Statement End Date] BETWEEN DATEADD( DAY, 1, DATEADD( MONTH, -61, GETDATE() ) ) AND EOMONTH( DATEADD( MONTH, -1, GETDATE() ) )


/*******************************************************************************************************************/

SELECT
 LOS.CLAIM_STATUS
,[LOS Adjusted by 1] =
	SUM( [LOS Adjusted by 1]  )
,[LOS] =
	SUM( LOS.LOS )
FROM
#LOS AS LOS
GROUP BY
LOS.CLAIM_STATUS

SELECT
 CLAIM_STATUS
,[MedInsight LOS] =
	SUM( Medinsight.LOS )
FROM
#Medinsight AS Medinsight
GROUP BY
CLAIM_STATUS

SELECT
 [CLAIM_STATUS]
,[Adjudicated Room and Board LOS] =
	SUM( RandBAdjudicated.LOS )
FROM
#RandBAdjudicated AS RandBAdjudicated
GROUP BY
[CLAIM_STATUS]

SELECT
 [CLAIM_STATUS]
,[Room and Board LOS] =
	SUM( RandBA.LOS )
FROM
#RandB AS RandBA
GROUP BY
[CLAIM_STATUS]

SELECT
 [CLAIM_STATUS]
,[Erik's LOS] =
	SUM( #EriksLOS.[Erik's LOS] )
FROM
#EriksLOS
GROUP BY
[CLAIM_STATUS]

SELECT
 [CLAIM_STATUS]
,[Last Claim LOS] =
	SUM( #LastClaimLOS.LOS )
FROM
#LastClaimLOS
GROUP BY
[CLAIM_STATUS]
