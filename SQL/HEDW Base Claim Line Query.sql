SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--/******************************************************************************/
--/*
--PURPOSE: TRY TO BUILD A COMPLETE SET OF JOINS TO ALLOW FOR A QUICK PULL OF INFORMATION RELATED TO THE HEDW CLAIM(LINE) INFO.
--*/

--/******************************************************************************/
--/* CLAIM LINE FACT TO REPRICER - REMOVE IF UNNECCESARY - AS OF 2016/11/10 RUNTIME IS 0:00 m:s */

--/*****************************************/
--/* CREATE A TABLE OF LINES WITH MULTIPLE REPRICERS ( UNIQUE ) */

--IF OBJECT_ID( 'TEMPDB..#MultipleRepricers' ) IS NOT NULL DROP TABLE #MultipleRepricers;

--SELECT 
--[CLAIM_LINE_FACT_KEY]
--INTO
--#MultipleRepricers
--FROM
--[wea_prod_dw].[dbo].[CLM_LN_FACT_TO_REPRICER_OUTPUT]
--GROUP BY
--[CLAIM_LINE_FACT_KEY]
--HAVING
--COUNT(*) > 1;

--/******************************************************************************/
--/* ADJUDICATION MESSAGE DENORMALIZATION - REMOVE IF UNNECCESARY - AS OF 2016/10/10 RUNTIME IS : m:s */

--/*****************************************/
--/* INITIALIZE LOCAL AND GLOBAL TEMP TABLES */

--IF OBJECT_ID( 'TEMPDB..##AdjudicationMessages' ) IS NOT NULL DROP TABLE ##AdjudicationMessages;
--GO

--IF OBJECT_ID( 'TEMPDB..#AdjudicationMessage' ) IS NOT NULL DROP TABLE #AdjudicationMessage;
--GO

--/*****************************************/
--/* DECLARE PARAMETERS */

--DECLARE 
-- @cols AS NVARCHAR( MAX )
--,@query  AS NVARCHAR( MAX );

--/*****************************************/
--/* RANK ALL MESSAGES OVER THE CLAIM LINES */

--SELECT
-- ClfToMes.[CLAIM_LINE_FACT_KEY]
--,AdjMes.[ADJUDICATION_MESSAGE_DESC]
--,'Adjudication Message ' + CAST( ROW_NUMBER() OVER( PARTITION BY ClfToMes.CLAIM_LINE_FACT_KEY ORDER BY ClfToMes.ReplIdentity ) AS VARCHAR( 3 ) ) AS 'Rank'
--INTO 
--#AdjudicationMessage
--FROM 
--[wea_prod_dw].[dbo].[CLAIM_LINE_FACT_TO_ADJD_MSG] AS ClfToMes
	
--	LEFT JOIN wea_prod_dw.dbo.ADJUDICATION_MESSAGE AS AdjMes
--		ON AdjMes.ADJUDICATION_MESSAGE_KEY = ClfToMes.ADJUDICATION_MESSAGE_KEY

--/* FOR DEBUGGING */  --SELECT TOP 100 * FROM #AdjudicationMessage

--/*****************************************/
--/* DENORMALIZE THE COLUMN NAMES */

--SELECT 
--@cols = STUFF( ( SELECT ',' + QUOTENAME( [Rank] ) 
--                    FROM #AdjudicationMessage
--                    GROUP BY [Rank]
--                    ORDER BY CAST( SUBSTRING( [Rank], 21, LEN( [Rank] ) ) AS INT )
--            FOR XML PATH(''), TYPE
--            ).value('.', 'NVARCHAR(MAX)') 
--        ,1,1,'')

--/*****************************************/
--/* DEFINE THE DYNAMIC QUERY */

--SET
-- @query = 
 
-- (
-- 'SELECT
-- [CLAIM_LINE_FACT_KEY]
--,' + @cols + ' INTO ##AdjudicationMessages
--FROM 
--	(

--	SELECT 
--	 [CLAIM_LINE_FACT_KEY]
--	,[Rank]
--	,[ADJUDICATION_MESSAGE_DESC]
--	FROM 
--	#AdjudicationMessage

--	) x
--PIVOT 
--(
--MAX( [ADJUDICATION_MESSAGE_DESC] )
--FOR 
--[Rank] IN ( ' + @cols + ' )
--) p ' 

--)

--/*****************************************/
--/* EXECUTE THE DYNAMIC QUERY */

--EXECUTE( @query );

--/* FOR DEBUGGING */ --SELECT TOP 100* FROM ##AdjudicationMessages

--/*****************************************/
--/* REMOVE THE UNNECESSARY TEMP TABLE */

--IF OBJECT_ID( 'TEMPDB..#AdjudicationMessage' ) IS NOT NULL DROP TABLE #AdjudicationMessage;

/******************************************************************************/
/* QUERY TO GRAB HEDW CLAIM LINE INFORMATION */

SELECT

/* CLAIM INFO */

 [Claim Status] =
	Claim.CLAIM_STATUS
,Claim.IS_CURRENT
,[Claim Type Name] =
	Claim.CLAIM_TYPE_NAME
,[Patient Account Number] =
	Claim.PATIENT_ACCOUNT_NUMBER
,Claim.CLAIM_HCC_ID

--,[Clearinghouse #] =
--	CLEARING_HOUSE_TRACE_NUMBER
--,[External Batch #] =
--	EXTERNAL_CLAIM_BATCH_NUMBER
--,[External Claim ID] =
--	EXTERNAL_CLAIM_NUMBER
--,[Trading Partner ID] =
--	TRADING_PARTNER_ID

--,[Claim Earliest Adjudicated Date] =
--	CAST( Claim.[EARLIEST_ADJUDICATED_TIME] AS DATE )
--,[Claim Entry Date] =
--	CAST( Claim.[ENTRY_TIME] AS DATE )
-- Claim.CLAIM_FACT_KEY
--,Claim.EARLIEST_ADJUDICATED_DATE_KEY
--,Claim.ENTRY_DATE_KEY
--,Claim.IS_ADJUSTED
--,Claim.MOST_RECENT_PROCESS_DATE_KEY
,[Type Of Bill Code] =
	Claim.TYPE_OF_BILL_CODE
,[Type Of Bill Code Description] =
	TypeOfBill.TYPE_OF_BILL_DESC
,[Admit Status Code] =
	TypeOfBill.ADMIT_STATUS_CODE

/* CLAIM LINE INFO */

,[Claim Line Status Code] =
	ClaimLine.CLAIM_LINE_STATUS_CODE
,ClaimLine.CLAIM_LINE_HCC_ID
,[Service Code] =
	ClaimLine.SERVICE_CODE
,[Service Code Description] =
	ServiceCode.SERVICE_SHORT_DESC
,[Service Units] =
	ClaimLine.UNIT_COUNT
,[Billed] =
	ClaimLine.BILLED_AMOUNT
,[Allowed] =
	ClaimLine.BASE_ALLOWED_AMOUNT
,[Paid] =
	ClaimLine.PAID_AMOUNT
--,[Percentage of Billed] =
--	CASE
--		WHEN ISNULL( ClaimLine.BILLED_AMOUNT, 0 )  = 0 THEN NULL
--		ELSE CAST( ISNULL( ClaimLine.BASE_ALLOWED_AMOUNT, 0 ) / ClaimLine.BILLED_AMOUNT AS NUMERIC( 18,2 ) )
--	END
--,ClaimLine.CLAIM_LINE_FACT_KEY
--,ClaimLine.INGENIX_CLAIM_LINE_RESULT_KEY
--,ClaimLine.AUTH_FACT_KEY
--,ClaimLine.EFFECTIVE_ALLOWED_AMOUNT
--,ClaimLine.ALTERNATE_SERVICE_ALLOWED_AMT
--,ClaimLine.MANUAL_ALLOWED_AMOUNT
--,ClaimLine.PREDENIAL_ALLOWED_AMOUNT
--,ClaimLine.STATISTICAL_ALLOWED_AMOUNT
--,ClaimLine.BASE_CAPPED_ALLOWED_MEM_EXCESS
--,ClaimLine.COB_HCC_SAVINGS
--,ClaimLine.BASE_BALANCE_BILL_MEMBER_AMT AS 'Member Balance Billed Amount'
--,ClaimLine.BASE_MEMBER_RESP_AMOUNT AS 'Member Responsible Amount'
--,ClaimLine.BASE_NON_COVERED_AMOUNT AS 'Non-Covered Amount'
--,ClaimLine.BASE_COPAY_AMOUNT AS 'Copay'
--,ClaimLine.BASE_DEDUCTIBLE_AMOUNT AS 'Deductible'
--,ClaimLine.BASE_COINSURANCE_AMOUNT AS 'Coinsurance'
--,ClaimLine.BASE_PAID_AMOUNT
--,ClaimLine.MANUAL_REPRICER_KEY
--,ClaimLine.EMERGENCY_STATUS
--,ClaimLine.IS_SPLIT
,[Place Of Service Code] =
	ClaimLine.PLACE_OF_SERVICE_CODE
,[Place Of Service Code Description] =
	POS.PLACE_OF_SERVICE_DESC
,[Revenue Code] =
	ClaimLine.REVENUE_CODE
,[Revenue Code Description] = 
	RevenueCode.SERVICE_SHORT_DESC
--,ClaimLine.SERVICE_START_DATE_KEY
--,CLSC.CLAIM_LINE_STATUS_DESC
--,CLTC.CLAIM_LINE_TYPE_DESC
--,CLTC.CLAIM_LINE_TYPE_NAME

/* AUTHORIZATIONS */

,AuthFact.[AUTH_HCC_ID]
,AuthFact.AUTH_STATUS_CODE

,ars.REFERRAL_SERVICE_DESC
,ars.SERVICE_CATEGORY_NAME
,ars.[IS_CATEGORY]
,ars.[IS_SERVICE]

,ausc.AUTH_STATUS_DESC

,AuthServiceFact.AUTH_SERV_SET_STATUS_CODE
,AuthServiceFact.AUTH_SERV_SET_FACT_KEY

,asssc.AUTH_SERV_SET_STATUS_NAME

,[Auth Approved Unit Count] =
	AuthServiceFact.[AUTH_BENEFIT_COUNT_APPROVED]

,[Deny Indicator] =
	CASE
		WHEN AuthServiceFact.AUTH_SERV_SET_STATUS_CODE IN ('D','U') Then 1
		ELSE 0
	END

,[Approve Indicator] =
	CASE
		WHEN AuthServiceFact.AUTH_SERV_SET_STATUS_CODE IN ('A') THEN 1
		ELSE 0
	END

,[Authorized on Date] =
	CAST( dteAuthOn.DATE_VALUE AS DATE )

,[Authorized on Year Month] =
	dteAuthOn.MONTH_NUMBER_WITH_YEAR

,[Authorized on Qtr Year] =
	dteAuthOn.QUARTER_NAME_WITH_YEAR

,[Auth Setting] =
	CASE
		WHEN AuthFact.[AUTH_ADMIT_STATUS_CODE] = 'I' THEN 'IP' -- categorize IP from OP
		ELSE 'OP'
	END


,AuthFact.[AUTH_ADMIT_STATUS_CODE]
	   

,[Authorization Procedure] =
	Case
		WHEN AuthFact.[AUTH_ADMIT_STATUS_CODE] = 'I' AND IS_CATEGORY = 'Y' THEN CONCAT('IP','_',SERVICE_CATEGORY_NAME)
		WHEN AuthFact.[AUTH_ADMIT_STATUS_CODE] = 'O' AND IS_CATEGORY = 'Y' THEN CONCAT('OP','_',SERVICE_CATEGORY_NAME)
		WHEN AuthFact.[AUTH_ADMIT_STATUS_CODE] = 'I' AND IS_CATEGORY = 'N' THEN CONCAT('IP','_',REFERRAL_SERVICE_DESC)
		WHEN AuthFact.[AUTH_ADMIT_STATUS_CODE] = 'O' AND IS_CATEGORY = 'N' THEN CONCAT('OP','_',REFERRAL_SERVICE_DESC)
		ELSE 'Unknown'-- break PA Procedures into IP and OP buckets
	END

,[Authorization Type] =
	CASE
		WHEN ars.IS_CATEGORY = 'Y' THEN 'Category'
		ELSE 'Service'
	END

/* NDC */

,[NDC Code] =
	NDC.NDC_CODE
,[NDC Code Description] =
	NDCService.SERVICE_SHORT_DESC
--,[NDC Standardized Service Code] =
--	NDCService.STANDARDIZED_SERVICE_CODE
--,NDC.PRICE
,[NDC Quantity] =
	NDC.QUANTITY
,[NDC Measurement Type] =
	NDC.MEASUREMENT_TYPE_CODE

/* DIAGNOSIS */

--,[Claim Primary Diagnosis Code] =
--	Claim.PRIMARY_DIAGNOSIS_CODE
--,[Claim Primary Diagnosis Code Description] =
--	ClaimPrimaryDiagnosis.DIAGNOSIS_SHORT_DESC

--,[Claim Line Primary Diagnosis Code] =
--	ClaimLine.PRIMARY_DIAGNOSIS_CODE
--,[Claim Line Primary Diagnosis Code Description] =
--	ClaimLinePrimaryDiagnosis.DIAGNOSIS_SHORT_DESC

,[Claim Line Diagnosis Code 1] =
	Dx1.DIAGNOSIS_CODE
,[Claim Line Diagnosis Description 1] =
	Dx1.DIAGNOSIS_SHORT_DESC
,[Claim Line Diagnosis Code 2] =
	Dx2.DIAGNOSIS_CODE
,[Claim Line Diagnosis Description 2] =
	Dx2.DIAGNOSIS_SHORT_DESC
,[Claim Line Diagnosis Code 3] =
	Dx3.DIAGNOSIS_CODE
,[Claim Line Diagnosis Description 3] =
	Dx3.DIAGNOSIS_SHORT_DESC
,[Claim Line Diagnosis Code 4] =
	Dx4.DIAGNOSIS_CODE
,[Claim Line Diagnosis Description 4] =
	Dx4.DIAGNOSIS_SHORT_DESC

/* MODIFIERS */

,[Modifier Code 1] =
	Mod1.MODIFIER_CODE
,[Modifier Code 1 Description] =
	Mod1.MODIFIER_DESC
,[Modifier Code 2] =
	Mod2.MODIFIER_CODE
,[Modifier Code 2 Description] =
	Mod2.MODIFIER_DESC
,[Modifier Code 3] =
	Mod3.MODIFIER_CODE
,[Modifier Code 3 Description] =
	Mod3.MODIFIER_DESC
,[Modifier Code 4] =
	Mod4.MODIFIER_CODE
,[Modifier Code 4 Description] =
	Mod4.MODIFIER_DESC

/* DATES */

--,[Clean Claim Line Date] =
--	CAST( CleanClaimLineDate.DATE_VALUE AS DATE ) AS 'Clean Claim Line Date'
,[Service Start Date] =
	CAST( ServiceStartDate.DATE_VALUE AS DATE )
,[Service End Date] =
	CAST( ServiceEndDate.DATE_VALUE AS DATE )
,[Admit Date] =
	CAST( AdmitDate.DATE_VALUE AS DATE )
,[Discharge Date] =
	CAST( DischargeDate.DATE_VALUE AS DATE )
--,[Original Process Date] =
--	CAST( OriginalProcessDate.DATE_VALUE AS DATE )
--,[Receipt Date] =
--	CAST( ReceiptDate.DATE_VALUE AS DATE )
,[Claim Start Date] =
	CAST( StatementStartDate.DATE_VALUE AS DATE )
,[Claim End Date] =
	CAST( StatementEndDate.DATE_VALUE AS DATE )
,[Process Date] =
	CAST( Claim.MOST_RECENT_PROCESS_TIME AS DATE )

/* MEMBER INFO */

,MHF.MEMBER_HCC_ID
,[Member Name] =
	MHF.MEMBER_FULL_NAME
,[Member First Name] =
	MHF.MEMBER_FIRST_NAME
,[Member Last Name] =
	MHF.MEMBER_LAST_NAME
--,MHF.MEMBER_HISTORY_FACT_KEY
--,MHF.ACCOUNT_KEY
--,MHF.MEMBER_BIRTH_DATE_KEY
--,MHF.MEMBER_DEATH_DATE_KEY
--,MHF.MEMBER_EFFECTIVE_DATE_KEY
--,MHF.MEMBER_TERMINATION_DATE_KEY
--,MHF.VERSION_EFF_DATE_KEY
--,MHF.VERSION_EXP_DATE_KEY
--,MHF.MEMBER_KEY
--,MHF.SUBSCRIBER_FULL_NAME
--,MHF.SUBSCRIPTION_HCC_ID
--,MHF.MEMBER_GENDER_CODE

/* ACCOUNT INFO */

,AHF.ACCOUNT_HCC_ID
,[Account Name] =
	AHF.ACCOUNT_NAME

,[Top Account ID] =
	TopAHF.ACCOUNT_HCC_ID
,[Top Account Name] =
	TopAHF.ACCOUNT_NAME

,[Account Type Name] =
	AccountType.[ACCOUNT_TYPE_NAME]

/* SUPPLIER INFO */

,Supplier.SUPPLIER_HCC_ID
,[Supplier Name] =
	Supplier.SUPPLIER_NAME
--,Supplier.SUPPLIER_KEY
--,Supplier.SUPPLIER_HISTORY_FACT_KEY
--,SupplierTaxonomy1.PROVIDER_TAXONOMY_KEY
--,SupplierTaxonomy1.PROVIDER_TAXONOMY_CODE
--,SupplierTaxonomy1.PROVIDER_TAXONOMY_DESC
--,SupplierTaxonomy1.PROVIDER_TAXONOMY_NAME
--,SupplierTaxonomy1.CLASSIFICATION
--,SupplierTaxonomy1.[TYPE]
--,SupplierTaxonomy1.SPECIALIZATION

/* SUPPLIER NETWORK INFO */

--,[All Supplier Networks] =
--	REVERSE( STUFF( REVERSE( 
--	REPLACE( REPLACE( REPLACE( 
--	STUFF( ( 
--		  SELECT
--		  '; ' + 
--		  CASE WHEN SupplierNetwork.SUPPLIER_NETWORK_HCC_ID IS NULL THEN '' ELSE CONCAT( 'Supplier Network HCC ID: ', SupplierNetwork.SUPPLIER_NETWORK_HCC_ID, CHAR(10), CHAR(13) ) END +
--		  CASE WHEN SupplierNetwork.SUPPLIER_NETWORK_NAME IS NULL THEN '' ELSE CONCAT( 'Supplier Network Name: ', SupplierNetwork.SUPPLIER_NETWORK_NAME, CHAR(10), CHAR(13) ) END +
--		  CASE WHEN SupplierNetwork.SUPPLIER_NETWORK_STATUS IS NULL THEN '' ELSE CONCAT( 'Supplier Network Status: ', SupplierNetwork.SUPPLIER_NETWORK_STATUS, CHAR(10), CHAR(13) ) END
--		  + CHAR(10) + CHAR(13)

--          FROM
--			wea_prod_dw.dbo.SUPPLIER_TO_SUPPLIER_NETWORK AS Supplier2SupplierNetwork

--				LEFT JOIN wea_prod_dw.dbo.SUPPLIER_NETWORK_HISTORY_FACT AS SupplierNetwork
--					ON	SupplierNetwork.SUPPLIER_NETWORK_KEY = Supplier2SupplierNetwork.SUPPLIER_NETWORK_KEY
--          WHERE
--			Supplier2SupplierNetwork.SUPPLIER_KEY = Claim.SUPPLIER_KEY
--			AND
--			Claim.STATEMENT_END_DATE_KEY BETWEEN Supplier2SupplierNetwork.VERSION_EFF_DATE_KEY AND Supplier2SupplierNetwork.VERSION_EXP_DATE_KEY - 1
--			AND
--			Claim.STATEMENT_END_DATE_KEY BETWEEN SupplierNetwork.VERSION_EFF_DATE_KEY AND SupplierNetwork.VERSION_EXP_DATE_KEY - 1
--          ORDER BY
--		    SupplierNetwork.SUPPLIER_NETWORK_HCC_ID
--          FOR XML PATH( '' ) 
--		  )
--		  , 1, 1, '' )
	
--	, '&#x0D', '' ), '&amp;', '&' ), ';;', '
--	' )

--	), 1, 2, '' ) )

/* TAX ENTITY INFO */

,[Tax Name] =
	TaxEntity.TAX_NAME
,TaxEntity.TIN  --No SSNs
,TaxEntity.TAX_ID --Mingled with SSNs
--,[Tax ID] = --Use to Match to EDW
--	CAST( REPLACE( TAX_ID, '-', '' ) AS VARCHAR(9) ) 

/* PRACTITIONER INFORMATION */

,PHF.PRACTITIONER_FULL_NAME
--,PHF.PRACTITIONER_KEY
,PHF.PRACTITIONER_HCC_ID
--,PHF.PRIMARY_SPECIALTY_KEY
--,PHF.PRACTITIONER_HIST_FACT_KEY
,PHF.PRACTITIONER_NPI
--,PHF.IS_PCP

/* COB - COORDINATION OF BENEFITS */

--,[COB Indicator] =
--	CASE
--		WHEN COB.COB_PAYMENT_FACT_KEY IS NULL THEN 'No COB'
--		ELSE 'COB Claim Line'
--	 END
--,[COB Billed By Other Insurer] =
--	COB.BILLED_AMOUNT
--,[COB Allowed By Other Insurer] =
--	COB.ALLOWED_AMOUNT
--,[COB Paid By Other Insurer] =
--	COB.PAID_AMOUNT
--,[Member Responsibility Not Paid By Other Insurer] =
--	COB.MEMBER_RESPONSIBILITY

/* DRG INFO */

--,DRG.DRG_CODE
--,DRG.DRG_DESC
--,DRG.DRG_TYPE_NAME
--,DRG.DRG_STATUS

/* POSTAL ADDRESS */

--,TaxEntityPostalAddress.ADDRESS_LINE
--,TaxEntityPostalAddress.ADDRESS_LINE_2
--,TaxEntityPostalAddress.ADDRESS_LINE_3
--,TaxEntityPostalAddress.CITY_NAME
--,TaxEntityPostalAddress.STATE_CODE
--,TaxEntityPostalAddress.ZIP_CODE
--,ServiceRenderedAddress.[POSTAL_ADDRESS_KEY]
--,ServiceRenderedAddress.[ADDRESS_LINE]
--,ServiceRenderedAddress.[ADDRESS_LINE_2]
--,ServiceRenderedAddress.[ADDRESS_LINE_3]
--,ServiceRenderedAddress.[ADDRESS_TYPE]
--,ServiceRenderedAddress.[CITY_NAME]
--,ServiceRenderedAddress.[COUNTRY_CODE]
--,ServiceRenderedAddress.[COUNTRY_NAME]
--,ServiceRenderedAddress.[COUNTY_CODE]
--,ServiceRenderedAddress.[STATE_CODE]
--,ServiceRenderedAddress.[ZIP_CODE]
--,ServiceRenderedAddress.[ZIP_4_CODE]

/* REPRICING INFO */

--,CASE WHEN MultRepricer.CLAIM_LINE_FACT_KEY IS NOT NULL THEN 'Multiple Repricers Available'
--	  ELSE 'Other'
--	  END AS 'Multiple Repricer Indicator'
--,RO.REPRICER_OUTPUT_KEY
--,RO.REPRICER_AMOUNT
--,RO.REPRICER_DECISION_CODE
--,RO.REQUEST_DATE_KEY
--,RO.RESPONSE_DATE_KEY
--,RO.REPRICER_KEY
--,RDC.[REPRICER_DECISION_DESC]
--,RDC.[REPRICER_DECISION_NAME]
--,RHF.REPRICER_HISTORY_FACT_KEY
--,RHF.REPRICER_NAME

/* ADJUDICATION DETAILS */

--,AdjDetails.BENEFIT
--,AdjDetails.BENEFIT_WITH_VALUES
--,AdjDetails.BENEFIT_WITH_VALUES_AND_NAMES
,AdjDetails.PRICING_RULE
--,AdjDetails.PROVIDER_REQ_AUTH


/* FEE COMPONENT */
,[Fee Component Name] =
	FeeComponent.FEE_COMPONENT_NAME
,[Fee Component Description] =
	FeeComponent.[DESCRIPTION]
,[Fee Component Status] =
	FeeComponent.[FEE_COMPONENT_STATUS]

/* FEE DETAIL */

,[Fee Amount] =
	FeeDetail.FEE
,[Fee Service Code] =
	FeeDetail.SERVICE_CODE
,[Fee Modifier 1] =
	FeeDetail.MODIFIER_CODE1
,[Fee Modifier 2] =
	FeeDetail.MODIFIER_CODE2
,[Fee Revenue Code] =
	FeeDetail.REVENUE_CODE
,[Fee Schedule Name] =
	FeeSchedule.SCHEDULE_NAME

/* ADJUDICATION BENEFITS */

--,BNHF.BENEFIT_NETWORK_DESC
--,BNHF.BENEFIT_NETWORK_NAME
--,BT.IS_IN_NETWORK
--,BT.TIER_NAME

/* PRODUCT INFO */

--,P.PRODUCT_KEY
--,P.PRODUCT_DESC
,P.PRODUCT_HCC_ID
,[Product Name] =
	P.PRODUCT_NAME
,[Company ID] =
	ISNULL( P.SUB_COMPANY_HCC_ID, 'WEA Trust' )

,[Benefit Plan Type Name] =
	BenefitPlanType.BENEFIT_PLAN_TYPE_NAME

/* BENEFIT PLAN INFO */

--,BPHF.BENEFIT_PLAN_HCC_ID
--,BPHF.BENEFIT_PLAN_NAME
--,BPHF.VERSION_EFF_DATE_KEY
--,BPHF.VERSION_EXP_DATE_KEY

--,[Network Definition Component Name] =
--	NetworkDefinition.NETWORK_DEF_COMP_NAME

/* INGENIX RULES */

--,[All CES Mnemonics] =
--   STUFF( ( 
--		  SELECT
--		  '; ' + IngenixFlag.FLAG_MNEMONIC
--          FROM
--			wea_prod_dw.dbo.[CLAIM_LN_FCT_TO_EXT_RES] AS ClaimLineToCES

--				JOIN wea_prod_dw.dbo.INGNX_CLAIM_LINE_RES_TO_FLAGS AS ICLRTF
--					ON ICLRTF.INGENIX_CLAIM_LINE_RESULT_KEY = ClaimLineToCES.INGENIX_CLAIM_LINE_RESULT_KEY

--					JOIN wea_prod_dw.dbo.INGENIX_FLAG AS IngenixFlag
--						ON IngenixFlag.INGENIX_FLAG_KEY = ICLRTF.INGENIX_FLAG_KEY

--          WHERE
--		  ClaimLineToCES.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY
--          ORDER BY
--		    ICLRTF.[ReplIdentity]
--          FOR XML PATH( '' ) 
--		  )
--		  , 1, 1, '' )

--/* ADJUDICATION MESSAGE */

,[All Adjudication Message Codes] =
   STUFF( ( 
		  SELECT
		  '; ' + AdjudicationMessage.ADJUDICATION_MESSAGE_CODE
          FROM
			wea_prod_dw.[dbo].[CLAIM_LINE_FACT_TO_ADJD_MSG] AS ClaimLine2AdjudicationMessage
			
				JOIN wea_prod_dw.dbo.ADJUDICATION_MESSAGE  AS AdjudicationMessage
					ON AdjudicationMessage.[ADJUDICATION_MESSAGE_KEY] = ClaimLine2AdjudicationMessage.[ADJUDICATION_MESSAGE_KEY]

          WHERE
		  ClaimLine2AdjudicationMessage.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY
          ORDER BY
		   ClaimLine2AdjudicationMessage.CLAIM_LINE_FACT_KEY
		  ,ClaimLine2AdjudicationMessage.[ReplIdentity]
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )


--,CLMADJ.[ADJUDICATION MESSAGE 1]
--,CLMADJ.[ADJUDICATION MESSAGE 2]
--,CLMADJ.[ADJUDICATION MESSAGE 3]
--,CLMADJ.[ADJUDICATION MESSAGE 4]
--,CLMADJ.[ADJUDICATION MESSAGE 5]
--,CLMADJ.[ADJUDICATION MESSAGE 6]
--,CLMADJ.[ADJUDICATION MESSAGE 7]
--,CLMADJ.[ADJUDICATION MESSAGE 8]
--,CLMADJ.[ADJUDICATION MESSAGE 9]
--,CLMADJ.[ADJUDICATION MESSAGE 10]
--,CLMADJ.[ADJUDICATION MESSAGE 11]
--,CLMADJ.[ADJUDICATION MESSAGE 12]
--,CLMADJ.[ADJUDICATION MESSAGE 13]
--,CLMADJ.[ADJUDICATION MESSAGE 14]
--,CLMADJ.[ADJUDICATION MESSAGE 15]
--,CLMADJ.[ADJUDICATION MESSAGE 16]
--,CLMADJ.[ADJUDICATION MESSAGE 17]
--,CLMADJ.[ADJUDICATION MESSAGE 18]
--,CLMADJ.[ADJUDICATION MESSAGE 19]
--,CLMADJ.[ADJUDICATION MESSAGE 20]
--,CLMADJ.[ADJUDICATION MESSAGE 21]
--,CLMADJ.[ADJUDICATION MESSAGE 22]
--,CLMADJ.[ADJUDICATION MESSAGE 23]
--,CLMADJ.[ADJUDICATION MESSAGE 24]
--,CLMADJ.[ADJUDICATION MESSAGE 25]
--,CLMADJ.[ADJUDICATION MESSAGE 26]
--,CLMADJ.[ADJUDICATION MESSAGE 27]
--,CLMADJ.[ADJUDICATION MESSAGE 28]
--,CLMADJ.[ADJUDICATION MESSAGE 29]

FROM

/*************************************************************************************************/
/* CLAIM */

wea_prod_dw.dbo.CLAIM_FACT AS Claim

/*************************************************************************************************/
/* DRG */

	--LEFT JOIN wea_prod_dw.dbo.DRG_HISTORY_FACT AS DRG
	--	ON DRG.DRG_KEY = Claim.DRG_KEY
	--	AND Claim.STATEMENT_END_DATE_KEY BETWEEN DRG.VERSION_EFF_DATE_KEY AND DRG.VERSION_EXP_DATE_KEY - 1

/*************************************************************************************************/
/* SUPPLIER */

	LEFT JOIN wea_prod_dw.dbo.ALL_SUPPLIER_HISTORY_FACT AS Supplier
		ON Supplier.SUPPLIER_KEY = Claim.SUPPLIER_KEY
		AND Claim.STATEMENT_END_DATE_KEY BETWEEN Supplier.VERSION_EFF_DATE_KEY AND Supplier.VERSION_EXP_DATE_KEY - 1

		--LEFT JOIN wea_prod_dw.dbo.SPPLR_HSTRY_TO_PRVDR_TXNMY AS Supplier2Taxonomy
		--	ON Supplier2Taxonomy.SUPPLIER_HISTORY_FACT_KEY = Supplier.SUPPLIER_HISTORY_FACT_KEY
		--	AND Supplier2Taxonomy.SORT_ORDER = 1

		--	LEFT JOIN wea_prod_dw.dbo.PROVIDER_TAXONOMY AS SupplierTaxonomy1
		--		ON SupplierTaxonomy1.PROVIDER_TAXONOMY_KEY = Supplier2Taxonomy.PROVIDER_TAXONOMY_KEY

/*************************************************************************************************/
/* TAX ENTITY */

		LEFT JOIN [wea_prod_dw].[dbo].[TAX_ENTITY_HISTORY_FACT] AS TaxEntity
			ON TaxEntity.TAX_ENTITY_KEY = Supplier.TAX_ENTITY_KEY
			AND Claim.STATEMENT_END_DATE_KEY BETWEEN TaxEntity.VERSION_EFF_DATE_KEY AND TaxEntity.VERSION_EXP_DATE_KEY - 1

		--	LEFT JOIN [wea_prod_dw].[dbo].[POSTAL_ADDRESS] AS TaxEntityPostalAddress
		--		ON TaxEntityPostalAddress.POSTAL_ADDRESS_KEY = TaxEntity.TAX_ADDRESS_KEY

/*************************************************************************************************/
/* TYPE OF BILL */

	LEFT JOIN wea_prod_dw.dbo.TYPE_OF_BILL AS TypeOfBill
		ON TypeOfBill.TYPE_OF_BILL_CODE = Claim.TYPE_OF_BILL_CODE

/*************************************************************************************************/
/* CLAIM LINE */

	LEFT JOIN wea_prod_dw.dbo.ALL_CLAIM_LINE_FACT AS ClaimLine
		ON ClaimLine.CLAIM_FACT_KEY = Claim.CLAIM_FACT_KEY

		LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_TYPE_CODE AS CLTC
			ON CLTC.CLAIM_LINE_TYPE_CODE = ClaimLine.CLAIM_LINE_TYPE_CODE

		LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_STATUS_CODE AS CLSC
			ON CLSC.CLAIM_LINE_STATUS_CODE = ClaimLine.CLAIM_LINE_STATUS_CODE

		LEFT JOIN wea_prod_dw.dbo.POSTAL_ADDRESS AS ServiceRenderedAddress
			ON ServiceRenderedAddress.POSTAL_ADDRESS_KEY = ClaimLine.SERVICE_RENDERED_ADDRESS_KEY

/*************************************************************************************************/
/* AUTHORIZATION */

	LEFT JOIN wea_prod_dw.dbo.AUTH_FACT AS AuthFact
		ON AuthFact.AUTH_FACT_KEY = ClaimLine.AUTH_FACT_KEY

	LEFT JOIN wea_prod_dw.dbo.AUTH_SERV_SET_FACT AS AuthServiceFact
		ON	AuthServiceFact.AUTH_SERV_SET_FACT_KEY = ClaimLine.AUTH_SERV_SET_FACT_KEY

		LEFT JOIN [wea_prod_dw].[dbo].[AUTH_REFERRAL_SERVICE] ars
		on AuthServiceFact.AUTH_REFERRAL_SERVICE_KEY = ars.AUTH_REFERRAL_SERVICE_KEY

		LEFT JOIN [wea_prod_dw].[dbo].[AUTH_STATUS_CODE] ausc
		on AuthFact.AUTH_STATUS_CODE = ausc.AUTH_STATUS_CODE

		LEFT JOIN [wea_prod_dw].[dbo].[DATE_DIMENSION] dteAuthOn
		on AuthServiceFact.AUTHORIZED_ON_DATE_KEY = dteAuthOn.DATE_KEY

		LEFT JOIN [wea_prod_dw].[dbo].[AUTH_SERV_SET_STATUS_CODE] asssc
		on AuthServiceFact.AUTH_SERV_SET_STATUS_CODE = asssc.AUTH_SERV_SET_STATUS_CODE

/*************************************************************************************************/
/* NDC */

		 LEFT JOIN [wea_prod_dw].[dbo].CLAIM_LN_FACT_TO_NDC_CODE_INFO AS ClmToNDC
			ON ClmToNDC.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY

			LEFT JOIN [wea_prod_dw].[dbo].[NDC_CODE_INFO_FACT] AS NDC
				ON NDC.NDC_CODE_INFO_KEY = ClmToNDC.NDC_CODE_INFO_KEY

				LEFT JOIN wea_prod_dw.dbo.NDC_MEASUREMENT_TYPE AS NDCMeasurementType
					ON NDCMeasurementType.[NDC_MEASUREMENT_TYPE_CODE] = NDC.[MEASUREMENT_TYPE_CODE]

				LEFT JOIN wea_prod_dw.dbo.[service] AS NDCService
					ON NDCService.SERVICE_CODE = NDC.NDC_CODE
					AND NDCService.SERVICE_TYPE_NAME = 'NDC 5-4-2'

/*************************************************************************************************/
/* DIAGNOSIS */
	
	LEFT JOIN wea_prod_dw.dbo.DIAGNOSIS AS ClaimPrimaryDiagnosis
		ON ClaimPrimaryDiagnosis.DIAGNOSIS_CODE = Claim.PRIMARY_DIAGNOSIS_CODE

		LEFT JOIN wea_prod_dw.dbo.DIAGNOSIS AS ClaimLinePrimaryDiagnosis
			ON ClaimLinePrimaryDiagnosis.DIAGNOSIS_CODE = ClaimLine.PRIMARY_DIAGNOSIS_CODE

		LEFT JOIN [wea_prod_dw].[dbo].[CLAIM_LINE_FACT_TO_DIAG] AS CLF2Dx1
			ON CLF2Dx1.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY
			AND CLF2Dx1.SORT_ORDER = 1

			LEFT JOIN wea_prod_dw.dbo.DIAGNOSIS AS DX1
				ON DX1.DIAGNOSIS_CODE = CLF2Dx1.DIAGNOSIS_CODE

		LEFT JOIN [wea_prod_dw].[dbo].[CLAIM_LINE_FACT_TO_DIAG] AS CLF2Dx2
			ON CLF2Dx2.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY
			AND CLF2Dx2.SORT_ORDER = 2

			LEFT JOIN wea_prod_dw.dbo.DIAGNOSIS AS DX2
				ON DX2.DIAGNOSIS_CODE = CLF2Dx2.DIAGNOSIS_CODE

		LEFT JOIN [wea_prod_dw].[dbo].[CLAIM_LINE_FACT_TO_DIAG] AS CLF2Dx3
			ON CLF2Dx3.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY
			AND CLF2Dx3.SORT_ORDER = 3

			LEFT JOIN wea_prod_dw.dbo.DIAGNOSIS AS DX3
				ON DX3.DIAGNOSIS_CODE = CLF2Dx3.DIAGNOSIS_CODE

		LEFT JOIN [wea_prod_dw].[dbo].[CLAIM_LINE_FACT_TO_DIAG] AS CLF2Dx4
			ON CLF2Dx4.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY
			AND CLF2Dx4.SORT_ORDER = 4

			LEFT JOIN wea_prod_dw.dbo.DIAGNOSIS AS DX4
				ON DX4.DIAGNOSIS_CODE = CLF2Dx4.DIAGNOSIS_CODE

/*************************************************************************************************/
/* PRACTITIONER */

		LEFT JOIN wea_prod_dw.dbo.ALL_PRACTITIONER_HISTORY_FACT AS PHF
			ON PHF.PRACTITIONER_KEY = ClaimLine.PRACTITIONER_KEY
			AND Claim.STATEMENT_END_DATE_KEY BETWEEN PHF.VERSION_EFF_DATE_KEY AND PHF.VERSION_EXP_DATE_KEY - 1

/*************************************************************************************************/
/* PLACE OF SERVICE */

		LEFT JOIN wea_prod_dw.dbo.PLACE_OF_SERVICE AS POS
			ON POS.PLACE_OF_SERVICE_CODE = ClaimLine.PLACE_OF_SERVICE_CODE

/*************************************************************************************************/
/* SERVICE/CPT/HCPCS CODE */

		LEFT JOIN wea_prod_dw.dbo.[SERVICE] AS ServiceCode
			ON ClaimLine.SERVICE_CODE = ServiceCode.SERVICE_CODE

/*************************************************************************************************/
/* REVENUE CODE */

		LEFT JOIN wea_prod_dw.dbo.[SERVICE] AS RevenueCode
			ON ClaimLine.REVENUE_CODE = RevenueCode.SERVICE_CODE

/*************************************************************************************************/
/* MODIFIER */

		LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT_TO_MODIFIER AS CLF2Mod1
			ON CLF2Mod1.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY
			AND CLF2Mod1.SORT_ORDER = 1

			LEFT JOIN wea_prod_dw.dbo.MODIFIER AS Mod1
				ON Mod1.MODIFIER_CODE = CLF2Mod1.MODIFIER_CODE

		LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT_TO_MODIFIER AS CLF2Mod2
			ON CLF2Mod2.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY
			AND CLF2Mod2.SORT_ORDER = 2

			LEFT JOIN wea_prod_dw.dbo.MODIFIER AS Mod2
				ON Mod2.MODIFIER_CODE = CLF2Mod2.MODIFIER_CODE

		LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT_TO_MODIFIER AS CLF2Mod3
			ON CLF2Mod3.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY
			AND CLF2Mod3.SORT_ORDER = 3

			LEFT JOIN wea_prod_dw.dbo.MODIFIER AS Mod3
				ON Mod3.MODIFIER_CODE = CLF2Mod3.MODIFIER_CODE

		LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT_TO_MODIFIER AS CLF2Mod4
			ON CLF2Mod4.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY
			AND CLF2Mod4.SORT_ORDER = 4

			LEFT JOIN wea_prod_dw.dbo.MODIFIER AS Mod4
				ON Mod4.MODIFIER_CODE = CLF2Mod4.MODIFIER_CODE

/*************************************************************************************************/
/* ADJUDICATION MESSAGE - REMOVE IF UNNECCESARY */

		--LEFT JOIN ##AdjudicationMessages AS CLMADJ
		--	ON CLMADJ.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY

/*************************************************************************************************/
/* DATES */

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS AdmitDate
		ON AdmitDate.DATE_KEY = Claim.ADMISSION_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS DischargeDate
		ON DischargeDate.DATE_KEY = Claim.DISCHARGE_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS OriginalProcessDate
		ON OriginalProcessDate.DATE_KEY = Claim.ORIGINAL_PROCESS_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS ReceiptDate
		ON ReceiptDate.DATE_KEY = Claim.RECEIPT_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS StatementStartDate
		ON StatementStartDate.DATE_KEY = Claim.STATEMENT_START_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS StatementEndDate
		ON StatementEndDate.DATE_KEY = Claim.STATEMENT_END_DATE_KEY

		LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS CleanClaimLineDate
			ON CleanClaimLineDate.DATE_KEY = ClaimLine.CLEAN_CLAIM_LINE_DATE_KEY

		LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS ServiceStartDate
			ON ServiceStartDate.DATE_KEY = ClaimLine.SERVICE_START_DATE_KEY

		LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS ServiceEndDate
			ON ServiceEndDate.DATE_KEY = ClaimLine.SERVICE_END_DATE_KEY

/*************************************************************************************************/
/* COB */

		--LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FCT_TO_COB_PAYMENT AS CLF2COB
		--	ON CLF2COB.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY
		
		--	LEFT JOIN wea_prod_dw.dbo.COB_PAYMENT_FACT AS COB
		--		ON COB.COB_PAYMENT_FACT_KEY = CLF2COB.COB_PAYMENT_FACT_KEY

/*************************************************************************************************/
/* REPRICER */

		--LEFT JOIN #MultipleRepricers AS MultRepricer
		--	ON MultRepricer.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY

		--	LEFT JOIN wea_prod_dw.dbo.CLM_LN_FACT_TO_REPRICER_OUTPUT AS CLFToRepr
		--		ON CLFToRepr.CLAIM_LINE_FACT_KEY = ClaimLine.CLAIM_LINE_FACT_KEY
		--		AND MultRepricer.CLAIM_LINE_FACT_KEY IS NULL

		--		LEFT JOIN wea_prod_dw.dbo.REPRICER_OUTPUT AS RO
		--			ON RO.REPRICER_OUTPUT_KEY = CLFToRepr.REPRICER_OUTPUT_KEY

		--			LEFT JOIN wea_prod_dw.dbo.REPRICER_DECISION_CODE AS RDC
		--				ON RDC.REPRICER_DECISION_CODE = RO.REPRICER_DECISION_CODE

		--			LEFT JOIN wea_prod_dw.dbo.REPRICER_HISTORY_FACT AS RHF
		--				ON RHF.REPRICER_KEY = RO.REPRICER_KEY
		--				AND Claim.STATEMENT_END_DATE_KEY BETWEEN RHF.VERSION_EFF_DATE_KEY AND RHF.VERSION_EXP_DATE_KEY - 1

/*************************************************************************************************/
/* ADJUDICATION DETAILS */

		LEFT JOIN wea_prod_dw.dbo.ADJUDICATION_DETAILS AS AdjDetails
			ON AdjDetails.ADJUDICATION_DETAILS_KEY = ClaimLine.ADJUDICATION_DETAILS_KEY

			LEFT JOIN wea_prod_dw.dbo.FEE_COMPONENT_HISTORY_FACT AS FeeComponent
				ON	FeeComponent.FEE_COMPONENT_KEY = AdjDetails.FEE_COMPONENT_KEY
				AND Claim.STATEMENT_END_DATE_KEY BETWEEN FeeComponent.VERSION_EFF_DATE_KEY AND FeeComponent.VERSION_EXP_DATE_KEY - 1

			LEFT JOIN [wea_prod_dw].[dbo].[BENEFIT_NETWORK_HISTORY_FACT] AS BNHF
				ON BNHF.BENEFIT_NETWORK_KEY = AdjDetails.BENEFIT_NETWORK_KEY
				AND Claim.STATEMENT_END_DATE_KEY BETWEEN BNHF.VERSION_EFF_DATE_KEY AND BNHF.VERSION_EXP_DATE_KEY - 1

			LEFT JOIN wea_prod_dw.dbo.BENEFIT_TIER AS BT
				ON BT.BENEFIT_TIER_KEY = AdjDetails.BENEFIT_TIER_KEY

/*************************************************************************************************/
/* FEE DETAIL */

		LEFT JOIN wea_prod_dw.dbo.FEE_DETAIL_HISTORY_FACT AS FeeDetail
			ON	FeeDetail.FEE_DETAIL_KEY = ClaimLine.FEE_DETAIL_KEY
			AND Claim.STATEMENT_END_DATE_KEY BETWEEN FeeDetail.VERSION_EFF_DATE_KEY AND FeeDetail.VERSION_EXP_DATE_KEY - 1

			LEFT JOIN wea_prod_dw.dbo.FEE_SCHEDULE_HISTORY_FACT AS FeeSchedule
				ON	FeeSchedule.FEE_SCHEDULE_KEY = FeeDetail.FEE_SCHEDULE_KEY
				AND Claim.STATEMENT_END_DATE_KEY BETWEEN FeeSchedule.VERSION_EFF_DATE_KEY AND FeeSchedule.VERSION_EXP_DATE_KEY - 1

/*************************************************************************************************/
/* PRODUCT */

		LEFT JOIN [wea_prod_dw].[dbo].[PRODUCT] AS P
			ON P.PRODUCT_KEY = ClaimLine.BASE_PRODUCT_KEY

			LEFT JOIN [wea_prod_dw].[dbo].[BENEFIT_PLAN_TYPE_CODE] AS BenefitPlanType
				ON BenefitPlanType.BENEFIT_PLAN_TYPE_KEY = P.BENEFIT_PLAN_TYPE_KEY

/*************************************************************************************************/
/* MEMBER */

	LEFT JOIN wea_prod_dw.dbo.ALL_MEMBER_HISTORY_FACT AS MHF
		ON MHF.MEMBER_KEY = Claim.MEMBER_KEY
		AND Claim.STATEMENT_END_DATE_KEY BETWEEN MHF.VERSION_EFF_DATE_KEY AND MHF.VERSION_EXP_DATE_KEY -1

/*************************************************************************************************/
/* ACCOUNT */

		LEFT JOIN wea_prod_dw.dbo.ALL_ACCOUNT_HISTORY_FACT AS AHF
			ON AHF.ACCOUNT_KEY = ClaimLine.ACCOUNT_KEY
			AND Claim.STATEMENT_END_DATE_KEY BETWEEN AHF.VERSION_EFF_DATE_KEY AND AHF.VERSION_EXP_DATE_KEY - 1

			LEFT JOIN wea_prod_dw.dbo.ALL_ACCOUNT_HISTORY_FACT AS TopAHF
				ON AHF.TOP_ACCOUNT_KEY = TopAHF.ACCOUNT_KEY
				AND Claim.STATEMENT_END_DATE_KEY BETWEEN TopAHF.VERSION_EFF_DATE_KEY AND TopAHF.VERSION_EXP_DATE_KEY - 1

				LEFT JOIN wea_prod_dw.dbo.ACCOUNT_TYPE_CODE AS AccountType
					ON AccountType.[ACCOUNT_TYPE_KEY] = TopAHF.[ACCOUNT_TYPE_KEY]

/*************************************************************************************************/
/* BENEFIT PLAN */

	LEFT JOIN wea_prod_dw.dbo.BENEFIT_PLAN_HISTORY_FACT AS BPHF
		ON BPHF.BENEFIT_PLAN_KEY = ClaimLine.BENEFIT_PLAN_KEY
		AND Claim.STATEMENT_END_DATE_KEY BETWEEN BPHF.VERSION_EFF_DATE_KEY AND BPHF.VERSION_EXP_DATE_KEY - 1 

		LEFT JOIN wea_prod_dw.dbo.BNFT_PLN_HST_FCT_TO_NEDEF_COMP AS BenefitPlanToNetworkDefinition
			ON	BenefitPlanToNetworkDefinition.BNFT_PLAN_HST_FCT_KEY = BPHF.BENEFIT_PLAN_HISTORY_FACT_KEY
			AND BenefitPlanToNetworkDefinition.SORT_ORDER = 1

			LEFT JOIN wea_prod_dw.dbo.NETWORK_DEF_COMP_HIST_FACT AS NetworkDefinition
				ON	NetworkDefinition.NETWORK_DEF_COMP_KEY = BenefitPlanToNetworkDefinition.NETWORK_DEF_COMP_KEY
				AND Claim.STATEMENT_END_DATE_KEY BETWEEN NetworkDefinition.VERSION_EFF_DATE_KEY AND NetworkDefinition.VERSION_EXP_DATE_KEY - 1

/*************************************************************************************************/

WHERE
--Claim.CLAIM_FACT_KEY = '17949528'
--MEMBER_HCC_ID = ''
--AND
--ServiceStartDate.DATE_VALUE = '2021-12-23'
--AND
--IS_CURRENT = 'Y'

--Claim.CLAIM_FACT_KEY = '16555834'
--MEMBER_HCC_ID = ''
--AND
--ServiceStartDate.DATE_VALUE = '2021-05-24'
--AND
--IS_CURRENT = 'Y'

--IF OBJECT_ID( 'TEMPDB..##AdjudicationMessages' ) IS NOT NULL DROP TABLE ##AdjudicationMessages;
--GO


/**************************************************************************************************************/
/**************************************************************************************************************/
/**************************************************************************************************************/
/**************************************************************************************************************/
