SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/**************************************************************************************************************/
/* INITIALIZE LANDING TABLE */

USE HCI_Stage;

IF OBJECT_ID( 'WEA.DN.MEDICAL_CLAIMS_SUPPLEMENT_2022_03_02' ) IS NOT NULL
	BEGIN
		DROP TABLE DN.MEDICAL_CLAIMS_SUPPLEMENT_2022_03_02
	END;

/**************************************************************************************************************/
/* ER or Urgent */

IF OBJECT_ID( 'TEMPDB.DBO.#UrgentOrEmergent' ) IS NOT NULL
	BEGIN
		DROP TABLE #UrgentOrEmergent
	END;

SELECT
Med.CLAIM_FACT_KEY
INTO
#UrgentOrEmergent
FROM
WEA.DN.MEDICAL_CLAIMS_VIEW AS Med

	LEFT JOIN WEA_EDW.FACT.CLAIM_FACT AS Claim
		ON	Claim.CLAIM_FACT_KEY = Med.CLAIM_FACT_KEY

		LEFT JOIN WEA_EDW.DIM.ADMIT_TYPE_DIM AS AdmitType
			ON	AdmitType.ADMIT_TYPE_DIM_KEY = Claim.CLAIM_ADMIT_TYPE_DIM_KEY

	LEFT JOIN [wea_prod_dw].[dbo].[CLAIM_FACT] AS ClaimFact
		ON	ClaimFact.CLAIM_FACT_KEY = Med.CLAIM_FACT_KEY

		LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS AccidentDate
			ON	AccidentDate.DATE_KEY = ClaimFact.ACCIDENT_DATE_KEY
WHERE
Med.[Place Of Service Description] IN (
 'Emergency Room – Hospital'
,'Urgent Care Facility'
,'Ambulance - Land'
,'Ambulance – Air or Water'
)
OR
AdmitType.ADMIT_TYPE_NAME IN (
 'Urgent'
,'Emergency'
,'Out of network Emergency Medical Care'
,'Trauma Ctr'
)
OR
AccidentDate.DATE_VALUE IS NOT NULL
GROUP BY
Med.CLAIM_FACT_KEY;

/**************************************************************************************************************/

DECLARE
 @CurrentDate	AS	DATE	= GETDATE()
,@LookBackYears	AS	INT		=	2
,@StartingDate	AS	DATE;

SET @StartingDate = DATEADD( YEAR, -1 * @LookBackYears, @CurrentDate );

/**************************************************************************************************************/

IF OBJECT_ID( 'TEMPDB.DBO.#AtlasCrosswalk' ) IS NOT NULL
	BEGIN
		DROP TABLE #AtlasCrosswalk
	END;

SELECT
 [Network Definition] =
	Parent.LookupDescription
,[Network EffDate] =
	Parent.EffDate
,[Network TermDate] =
	Parent.TermDate
,[Supplier Benefit Network] =
	Child.LookupDescription
,[Supplier Benefit Network EffDate] =
	Child.EffDate
,[Supplier Benefit Network TermDate] =
	Child.TermDate
,[Crosswalk EffDate] =
	Crosswalk.EffDate
,[Crosswalk TermDate] =
	Crosswalk.TermDate
INTO
#AtlasCrosswalk
FROM
/* Parent */
Atlas.lookup.CodeSet AS ParentsCodeSet

	JOIN Atlas.lookup.LookupValue AS Parent
		ON ParentsCodeSet.CodeSetID = Parent.CodeSetID

		/* Crosswalk */
		LEFT JOIN Atlas.lookup.Crosswalk AS Crosswalk
			ON	Parent.LookupID = Crosswalk.LookupID

		/* Child */
			LEFT JOIN Atlas.lookup.LookupValue AS Child
				ON	Child.LookupID = Crosswalk.CrosswalkLookupID

				LEFT JOIN Atlas.lookup.CodeSet AS ChildsCodeSet
					ON ChildsCodeSet.CodeSetID = Child.CodeSetID


WHERE
ParentsCodeSet.CodeSetName = 'NETWORK_DEF_COMP'
AND
ChildsCodeSet.CodeSetName = 'BENEFIT_NETWORK'

/* FOR DEBUGGING */ --SELECT TOP 100 * FROM #AtlasCrosswalk;

/**************************************************************************************************************/

IF OBJECT_ID( 'TEMPDB.DBO.#SupplierStatus' ) IS NOT NULL
	BEGIN
		DROP TABLE #SupplierStatus
	END;

SELECT
ClaimLine2AdjudicationMessage.CLAIM_LINE_FACT_KEY
INTO
#SupplierStatus
FROM
WEA_EDW.DIM.ADJUDICATION_MESSAGE_DIM AS AdjudicationMessage

	JOIN WEA_EDW.FACT.CLAIM_LINE_ADJUDICATION_MESSAGE_MAPPING_FACT AS ClaimLine2AdjudicationMessage
		ON ClaimLine2AdjudicationMessage.ADJUDICATION_MESSAGE_DIM_KEY = AdjudicationMessage.ADJUDICATION_MESSAGE_DIM_KEY

WHERE
ADJUDICATION_MESSAGE_CODE IN ( '147', '274' )
GROUP BY
ClaimLine2AdjudicationMessage.CLAIM_LINE_FACT_KEY
;

/**************************************************************************************************************/
/* Combine */

WITH Initial AS (

SELECT
/* Does not appear to work properly for manually adjudicated claims */
 [Supplier-Member Network Status - Adjudication Codes] =	
	CASE
		WHEN #SupplierStatus.CLAIM_LINE_FACT_KEY IS NOT NULL THEN 'Supplier is out of the member''s network'
		ELSE 'Supplier is in member''s network'
	END

/* May want to adapt this to use a process date instead of service date to more closely reflect what our system would do */
/* MHN, HSM Chiro/Therapy, transplant, oncology appear to always process in-network, likely because we leverage another network  (as does most of our repriced claims ) */
,[Supplier-Member Network Status - Atlas] =
	CASE
	WHEN EXISTS (
	SELECT
	SupplierBNHF.BENEFIT_NETWORK_NAME
	FROM
		wea_prod_dw.dbo.CLAIM_LINE_FACT AS ClaimLine

			JOIN wea_prod_dw.dbo.SUPPLIER_HISTORY_FACT AS SHF
				ON SHF.SUPPLIER_KEY = MedicalClaims.SUPPLIER_KEY
				AND ClaimLine.SERVICE_START_DATE_KEY BETWEEN SHF.VERSION_EFF_DATE_KEY AND SHF.VERSION_EXP_DATE_KEY - 1

				JOIN wea_prod_dw.dbo.[SUPPLIER_HIST_TO_BNFT_NETWORK] AS Supplier2BenefitNetwork
					ON Supplier2BenefitNetwork.SUPPLIER_HISTORY_FACT_KEY = SHF.SUPPLIER_HISTORY_FACT_KEY

					JOIN wea_prod_dw.dbo.BENEFIT_NETWORK_HISTORY_FACT AS SupplierBNHF
						ON SupplierBNHF.BENEFIT_NETWORK_KEY = Supplier2BenefitNetwork.BENEFIT_NETWORK_KEY
						AND ClaimLine.SERVICE_START_DATE_KEY BETWEEN SupplierBNHF.VERSION_EFF_DATE_KEY AND SupplierBNHF.VERSION_EXP_DATE_KEY - 1

						JOIN #AtlasCrosswalk
							ON #AtlasCrosswalk.[Supplier Benefit Network] = SupplierBNHF.BENEFIT_NETWORK_NAME
							AND MedicalClaims.[Service Start Date] BETWEEN [Crosswalk EffDate] AND [Crosswalk TermDate]
							AND MedicalClaims.[Service Start Date] BETWEEN [Supplier Benefit Network EffDate] AND [Supplier Benefit Network TermDate]
							AND MedicalClaims.[Service Start Date] BETWEEN [Network EffDate] AND [Network TermDate]

	WHERE
	#AtlasCrosswalk.[Network Definition] = MedicalClaims.NETWORK_DEFINITION_COMPONENT_NAME
	AND
	ClaimLine.CLAIM_LINE_FACT_KEY = MedicalClaims.CLAIM_LINE_FACT_KEY
		)
		  THEN 'Supplier is in member''s network'
	ELSE 'Supplier is out of member''s network'
END

,[Urgent or Emergent Status] =
	CASE
		WHEN MedicalClaims.BENEFIT LIKE '%and delivered on the same day as ( service category "Preventive - Colon CA" )%' THEN 'Other'
		WHEN MedicalClaims.BENEFIT LIKE '%not emergency care%' THEN 'Not Emergent'
		WHEN MedicalClaims.BENEFIT LIKE '%Not Same Day as ER%' THEN 'Not Emergent'
		WHEN MedicalClaims.BENEFIT LIKE '%Non-Emergency%' THEN 'Not Emergent'
		WHEN MedicalClaims.BENEFIT LIKE '%Non-ER%' THEN 'Not Emergent'
		WHEN MedicalClaims.BENEFIT LIKE '%emergency care%' THEN 'Emergent'
		WHEN MedicalClaims.BENEFIT LIKE '%Emergency Room%' THEN 'Emergent'
		WHEN MedicalClaims.BENEFIT LIKE '%Urgent Care%' THEN 'Urgent'
		ELSE 'Other'
	END
,[Service Category] =
	CASE
		WHEN CHARINDEX( 'service category "', MedicalClaims.BENEFIT ) > 0 THEN SUBSTRING( 
																		 MedicalClaims.BENEFIT
																		,CHARINDEX( 'service category "', MedicalClaims.BENEFIT ) + 18
																		,CHARINDEX( '"', MedicalClaims.BENEFIT, CHARINDEX( 'service category "', MedicalClaims.BENEFIT ) + 18 )  - CHARINDEX( 'service category "', MedicalClaims.BENEFIT ) - 18
																	)
		ELSE NULL
	END
,MedicalClaims.CLAIM_FACT_KEY
,MedicalClaims.CLAIM_LINE_FACT_KEY
,MedicalClaims.[Adjudicated Benefit Network Name]
FROM
WEA.DN.MEDICAL_CLAIMS_VIEW_ENHANCED AS MedicalClaims

	JOIN WEA_EDW.FACT.CLAIM_LINE_FACT AS CLF
		ON CLF.CLAIM_LINE_FACT_KEY = MedicalClaims.CLAIM_LINE_FACT_KEY

		JOIN WEA_EDW.DIM.ADJUDICATION_DETAILS_DIM AS AD
			ON	AD.ADJUDICATION_DETAILS_DIM_KEY = CLF.ADJUDICATION_DETAILS_DIM_KEY
	
	LEFT JOIN #SupplierStatus
		ON	#SupplierStatus.CLAIM_LINE_FACT_KEY = MedicalClaims.CLAIM_LINE_FACT_KEY

WHERE
MedicalClaims.[Statement End Date] >= @StartingDate
AND 
MedicalClaims.[Statement End Date] < @CurrentDate
AND
MedicalClaims.[VIP Member Indicator] = 'N'

),

UrgentEmergentStatus AS (

SELECT
 Initial.CLAIM_LINE_FACT_KEY
,Initial.[Supplier-Member Network Status - Adjudication Codes]
,[Supplier-Member Network Status - Atlas] =
	CASE
		WHEN Initial.[Adjudicated Benefit Network Name] IN ( 'HSM Chiro', 'HSM Therapy', 'MHN', 'Oncology Network', 'Transplant Network' ) THEN 'Supplier is in member''s network'
		ELSE Initial.[Supplier-Member Network Status - Atlas]
	END	
,Initial.[Service Category]
,Initial.[Urgent or Emergent Status]
,[Parent Service Category] =
	CASE
		WHEN Initial.[Service Category] LIKE '%COVID%' THEN 'COVID'
		WHEN Initial.[Service Category] LIKE '%Ambulance%' THEN 'Ambulance'
		WHEN Initial.[Service Category] LIKE '%High Tech Radiology%' THEN 'High Tech Radiology'
		WHEN Initial.[Service Category] LIKE '%Emergency Room%' THEN 'Emergency Room'
		WHEN Initial.[Service Category] LIKE '%Habilitative Therapy%' THEN 'Habilitative Therapy'
		WHEN Initial.[Service Category] LIKE '%Hearing%' THEN 'Hearing'
		WHEN Initial.[Service Category] LIKE '%Home Health%' THEN 'Home Health'
		WHEN Initial.[Service Category] LIKE '%Inpatient%' THEN 'Inpatient'
		WHEN Initial.[Service Category] LIKE '%Office Visit%' THEN 'Office Visit'
		WHEN Initial.[Service Category] LIKE '%Preventive%' THEN 'Preventive'
		WHEN Initial.[Service Category] LIKE '%Radiology%' THEN 'Radiology'
		WHEN Initial.[Service Category] LIKE '%Surgeon%' THEN 'Surgeon'
		WHEN Initial.[Service Category] LIKE '%Well Baby Care%' THEN 'Well Baby Care'
		WHEN Initial.[Service Category] LIKE '%Urgent Care%' THEN 'Urgent Care'
		WHEN Initial.[Service Category] LIKE '%Anesthesia%' THEN 'Anesthesia'
		ELSE 'Other'
	END


,[Urgent or Emergent Category] =
	CASE
		
		WHEN #UrgentOrEmergent.CLAIM_FACT_KEY IS NOT NULL THEN 'Urgent or Emergent'
		WHEN Initial.[Urgent or Emergent Status] IN ( 'Emergent', 'Urgent' ) THEN 'Urgent or Emergent'
		ELSE 'All Others'
	END

FROM
Initial

	LEFT JOIN #UrgentOrEmergent
		ON	#UrgentOrEmergent.CLAIM_FACT_KEY = Initial.CLAIM_FACT_KEY

)


SELECT
*
INTO
WEA.DN.MEDICAL_CLAIMS_SUPPLEMENT_2022_03_02
FROM
UrgentEmergentStatus
WHERE
1 = 1
