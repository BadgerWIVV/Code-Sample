USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[BSR 29304 - Create Output Table]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSR 29304 - Create Output Table] AS 
BEGIN

IF OBJECT_ID( '[DEPT_Actuary_JMarx].[dbo].[BSR 29304 - OUTBOUND - Health Claims Additional Info]' ) IS NOT NULL DROP TABLE [DEPT_Actuary_JMarx].[dbo].[BSR 29304 - OUTBOUND - Health Claims Additional Info];

/**************************************************************************************************************/
/* TRY - CATCH BLOCK: HANDLES AUTO INTERPRETATION OF CLAIMNUMBER AS EITHER VARCHAR OR FLOAT */

BEGIN TRY 

/**************************************************************************************************************/
/* ATTEMPTS TO CONVERT TO VARCHAR IF POSSIBLE */

IF OBJECT_ID( 'TEMPDB.DBO.#MaxClaimFact' ) IS NOT NULL DROP TABLE #MaxClaimFact;

SELECT
 Base.rownames
,[Max Claim Fact Key] =
	MAX( CF.[CLAIM_FACT_KEY] )
INTO
#MaxClaimFact
FROM
[DEPT_Actuary_JMarx].[dbo].[BSR 29304 - INBOUND - Health Claims Additional Info] AS Base

	LEFT JOIN wea_prod_dw.dbo.CLAIM_FACT AS CF
		ON CF.CLAIM_HCC_ID = CAST( CAST( Base.CLAIMNUMBER AS BIGINT ) AS VARCHAR(30) ) /* 8/6/2018 - Need to convert to VARCHAR for medical submissions. This requires convertint to BIGINT first to not use scientific notation */
		AND CF.IS_CURRENT = 'Y'

GROUP BY
Base.rownames;

END TRY

BEGIN CATCH

/**************************************************************************************************************/
/* IF UNABLE TO CONVERT TO VARCHAR, THEN LEAVES IT AS IS. THIS ASSUMES IT ALREADY IS A VARCHAR */

TRUNCATE TABLE #MaxClaimFact;

INSERT INTO #MaxClaimFact

SELECT
 Base.rownames
,[Max Claim Fact Key] =
	MAX( CF.[CLAIM_FACT_KEY] )
FROM
[DEPT_Actuary_JMarx].[dbo].[BSR 29304 - INBOUND - Health Claims Additional Info] AS Base

	LEFT JOIN wea_prod_dw.dbo.CLAIM_FACT AS CF
		ON CF.CLAIM_HCC_ID = Base.CLAIMNUMBER /* LEAVE THE DATA AS IS, IF THE AUTO CONVERSION USES VARCHAR */
		AND CF.IS_CURRENT = 'Y'

GROUP BY
Base.rownames;

END CATCH;

/**************************************************************************************************************/

WITH #ClaimAdjudicationMessages AS (

SELECT
 [Row Names] =
	CAST( Base.[rownames] AS INT )
,[MEMBER ID] =
	ISNULL( Base.[MEMBERID], '' )
,[GROUP NUMBER] =
	ISNULL( Base.[GROUPNUMBER], '' )
,[GROUP NAME] =
	ISNULL( Base.[GROUPNAME], '' )
,[DATE OF SERVICE TO] =
	ISNULL( Base.[DATEOFSERVICETO], '' )
,[DATE OF SERVICE FROM] =
	ISNULL( Base.[DATEOFSERVICEFROM], '' )
,[PROVIDER NAME] =
	ISNULL( Base.[PROVIDERNAME], '' )
,[CLAIM NUMBER] =
	ISNULL( Base.[CLAIMNUMBER], '' )
,[RECEIPT DATE] =
	ISNULL( Base.[RECEIPTDATE], '' )
,[DOCUMENT TYPE] =
	ISNULL( Base.[DOCUMENTTYPE], '' )
,[DOCUMENT SUBTYPE] =
	ISNULL( Base.[DOCUMENTSUBTYPE], '' )
,[LAST SEEN BY] =
	ISNULL( Base.[LASTSEENBY], '' )
,[DCN (Document ID)] =
	ISNULL( Base.[DCNDocumentID], '' )
,[Notes] =
	ISNULL( Base.[Notes], '' )
,[VIP] =
	ISNULL( Base.[VIP], '' )
,CF.CLAIM_HCC_ID
,CF.CLAIM_FACT_KEY
,[Adjudication Message Codes] =
   STUFF( ( 
		  SELECT
		  '; ' + AdjMes.ADJUDICATION_MESSAGE_CODE
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
				ON CLF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.[dbo].[CLAIM_LINE_FACT_TO_ADJD_MSG] AS ClfToMes
					ON ClfToMes.CLAIM_LINE_FACT_KEY = CLF.CLAIM_LINE_FACT_KEY

					LEFT JOIN wea_prod_dw.dbo.ADJUDICATION_MESSAGE AS AdjMes
						ON AdjMes.ADJUDICATION_MESSAGE_KEY = ClfToMes.ADJUDICATION_MESSAGE_KEY

          WHERE
		  CF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CLF.CLAIM_LINE_FACT_KEY
		  ,ClfToMes.ReplIdentity
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )
,[Adjudication Message Descriptions] =
   STUFF( ( 
		  SELECT 
		  '; ' + AdjMes.ADJUDICATION_MESSAGE_DESC
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
				ON CLF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.[dbo].[CLAIM_LINE_FACT_TO_ADJD_MSG] AS ClfToMes
					ON ClfToMes.CLAIM_LINE_FACT_KEY = CLF.CLAIM_LINE_FACT_KEY

					LEFT JOIN wea_prod_dw.dbo.ADJUDICATION_MESSAGE AS AdjMes
						ON AdjMes.ADJUDICATION_MESSAGE_KEY = ClfToMes.ADJUDICATION_MESSAGE_KEY

          WHERE
		  CF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CLF.CLAIM_LINE_FACT_KEY
		  ,ClfToMes.ReplIdentity
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )
FROM
[DEPT_Actuary_JMarx].[dbo].[BSR 29304 - INBOUND - Health Claims Additional Info] AS Base

	LEFT JOIN #MaxClaimFact AS MaxClaimFact
		ON MaxClaimFact.rownames = Base.rownames

		LEFT JOIN wea_prod_dw.dbo.CLAIM_FACT AS CF
			ON CF.CLAIM_FACT_KEY = MaxClaimFact.[Max Claim Fact Key]

),

#FirstAdjudicationMessages AS (

SELECT
 CAM.[Row Names]
,CAM.[MEMBER ID]
,CAM.[GROUP NUMBER]
,CAM.[GROUP NAME]
,CAM.[DATE OF SERVICE TO]
,CAM.[DATE OF SERVICE FROM]
,CAM.[PROVIDER NAME]
,CAM.[CLAIM NUMBER]
,CAM.[RECEIPT DATE]
,CAM.[DOCUMENT TYPE]
,CAM.[DOCUMENT SUBTYPE]
,CAM.[LAST SEEN BY]
,CAM.[DCN (Document ID)]
,CAM.[Notes]
,CAM.[VIP]
,CAM.CLAIM_HCC_ID
,CAM.CLAIM_FACT_KEY
,CAM.[Adjudication Message Codes]
,CAM.[Adjudication Message Descriptions] 
,[First Adjudication Message Code] =
	CASE
		WHEN CHARINDEX( ';', CAM.[Adjudication Message Codes], 0 ) > 0 THEN REPLACE( LEFT( CAM.[Adjudication Message Codes], CHARINDEX( ';', CAM.[Adjudication Message Codes], 0 ) ), ';', '' )
		ELSE CAM.[Adjudication Message Codes]
	END
,[First Adjudication Message Description] =
	CASE
		WHEN CHARINDEX( ';', CAM.[Adjudication Message Descriptions], 0 ) > 0 THEN REPLACE( LEFT( CAM.[Adjudication Message Descriptions], CHARINDEX( ';', CAM.[Adjudication Message Descriptions], 0 ) ), ';', '' )
		ELSE CAM.[Adjudication Message Descriptions]
	END
FROM
#ClaimAdjudicationMessages AS CAM

),

#SupplierTaxIDAndLineBilled AS (

SELECT
 FirstAM.[Row Names]
,FirstAM.[MEMBER ID]
,FirstAM.[GROUP NUMBER]
,FirstAM.[GROUP NAME]
,FirstAM.[DATE OF SERVICE TO]
,FirstAM.[DATE OF SERVICE FROM]
,FirstAM.[PROVIDER NAME]
,FirstAM.[CLAIM NUMBER]
,FirstAM.[RECEIPT DATE]
,FirstAM.[DOCUMENT TYPE]
,FirstAM.[DOCUMENT SUBTYPE]
,FirstAM.[LAST SEEN BY]
,FirstAM.[DCN (Document ID)]
,FirstAM.[Notes]
,FirstAM.[VIP]
,FirstAM.CLAIM_HCC_ID
,FirstAM.CLAIM_FACT_KEY
,FirstAM.[Adjudication Message Codes]
,FirstAM.[Adjudication Message Descriptions] 
,FirstAM.[First Adjudication Message Code]
,FirstAM.[First Adjudication Message Description]
,SHF.SUPPLIER_HCC_ID
,SHF.SUPPLIER_NAME
,TEHF.TIN
,TEHF.TAX_NAME
,[Billed Amounts on the Lines] =
   STUFF( ( 
		  SELECT 
		  '; ' + CAST( CLF.BILLED_AMOUNT AS VARCHAR(50) )
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
				ON CLF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

          WHERE
		  FirstAM.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CLF.CLAIM_LINE_FACT_KEY
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )
FROM
#FirstAdjudicationMessages AS FirstAM

	LEFT JOIN wea_prod_dw.dbo.CLAIM_FACT AS CF
		ON CF.CLAIM_FACT_KEY = FirstAM.CLAIM_FACT_KEY

		LEFT JOIN wea_prod_dw.dbo.SUPPLIER_HISTORY_FACT AS SHF
			ON SHF.SUPPLIER_KEY = CF.SUPPLIER_KEY
			AND CF.STATEMENT_END_DATE_KEY BETWEEN SHF.VERSION_EFF_DATE_KEY AND SHF.VERSION_EXP_DATE_KEY - 1 

			LEFT JOIN [wea_prod_dw].[dbo].[TAX_ENTITY_HISTORY_FACT] AS TEHF
				ON TEHF.TAX_ENTITY_KEY = SHF.TAX_ENTITY_KEY
				AND CF.STATEMENT_END_DATE_KEY BETWEEN TEHF.VERSION_EFF_DATE_KEY AND TEHF.VERSION_EXP_DATE_KEY - 1 
					
),

#ClaimBilled AS (

SELECT
 STLB.[Row Names]
,STLB.[MEMBER ID]
,STLB.[GROUP NUMBER]
,STLB.[GROUP NAME]
,STLB.[DATE OF SERVICE TO]
,STLB.[DATE OF SERVICE FROM]
,STLB.[PROVIDER NAME]
,STLB.[CLAIM NUMBER]
,STLB.[RECEIPT DATE]
,STLB.[DOCUMENT TYPE]
,STLB.[DOCUMENT SUBTYPE]
,STLB.[LAST SEEN BY]
,STLB.[DCN (Document ID)]
,STLB.[Notes]
,STLB.[VIP]
,STLB.CLAIM_HCC_ID
,STLB.CLAIM_FACT_KEY
,STLB.[Adjudication Message Codes]
,STLB.[Adjudication Message Descriptions] 
,STLB.[First Adjudication Message Code]
,STLB.[First Adjudication Message Description]
,STLB.SUPPLIER_HCC_ID
,STLB.SUPPLIER_NAME
,STLB.TIN
,STLB.TAX_NAME
,STLB.[Billed Amounts on the Lines]
,[Total Claim Billed] =
	SUM( CLF.BILLED_AMOUNT )
FROM
#SupplierTaxIDAndLineBilled AS STLB

	LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
		ON CLF.CLAIM_FACT_KEY = STLB.CLAIM_FACT_KEY
GROUP BY
 STLB.[Row Names]
,STLB.[MEMBER ID]
,STLB.[GROUP NUMBER]
,STLB.[GROUP NAME]
,STLB.[DATE OF SERVICE TO]
,STLB.[DATE OF SERVICE FROM]
,STLB.[PROVIDER NAME]
,STLB.[CLAIM NUMBER]
,STLB.[RECEIPT DATE]
,STLB.[DOCUMENT TYPE]
,STLB.[DOCUMENT SUBTYPE]
,STLB.[LAST SEEN BY]
,STLB.[DCN (Document ID)]
,STLB.[Notes]
,STLB.[VIP]
,STLB.CLAIM_HCC_ID
,STLB.CLAIM_FACT_KEY
,STLB.[Adjudication Message Codes]
,STLB.[Adjudication Message Descriptions] 
,STLB.[First Adjudication Message Code]
,STLB.[First Adjudication Message Description]
,STLB.SUPPLIER_HCC_ID
,STLB.SUPPLIER_NAME
,STLB.TIN
,STLB.TAX_NAME
,STLB.[Billed Amounts on the Lines]

),

#IngenixLineResults AS (

SELECT
 ClaimBilled.[Row Names]
,ClaimBilled.[MEMBER ID]
,ClaimBilled.[GROUP NUMBER]
,ClaimBilled.[GROUP NAME]
,ClaimBilled.[DATE OF SERVICE TO]
,ClaimBilled.[DATE OF SERVICE FROM]
,ClaimBilled.[PROVIDER NAME]
,ClaimBilled.[CLAIM NUMBER]
,ClaimBilled.[RECEIPT DATE]
,ClaimBilled.[DOCUMENT TYPE]
,ClaimBilled.[DOCUMENT SUBTYPE]
,ClaimBilled.[LAST SEEN BY]
,ClaimBilled.[DCN (Document ID)]
,ClaimBilled.[Notes]
,ClaimBilled.[VIP]
,ClaimBilled.CLAIM_HCC_ID
,ClaimBilled.CLAIM_FACT_KEY
,ClaimBilled.[Adjudication Message Codes]
,ClaimBilled.[Adjudication Message Descriptions] 
,ClaimBilled.[First Adjudication Message Code]
,ClaimBilled.[First Adjudication Message Description]
,ClaimBilled.SUPPLIER_HCC_ID
,ClaimBilled.SUPPLIER_NAME
,ClaimBilled.TIN
,ClaimBilled.TAX_NAME
,ClaimBilled.[Billed Amounts on the Lines]
,ClaimBilled.[Total Claim Billed]
,[Ingenix Enterprise ID] =
	ICR.INGNX_ENTERPRISE_ID
,[Ingenix Environment] =
	ICR.INGNX_ENVIRONMENT
,[Ingenix Processing Status Code] =
	ICR.PROCESSING_STATUS_CODE
,[Ingenix Line Result Dispositions] =
   STUFF( ( 
		  SELECT 
		  '; ' + ICLR.INGNX_DISPOSITION
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
				ON CLF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.dbo.INGENIX_CLAIM_LINE_RESULT AS ICLR
					ON ICLR.INGENIX_CLAIM_LINE_RESULT_KEY = CLF.INGENIX_CLAIM_LINE_RESULT_KEY

          WHERE
		  ClaimBilled.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CLF.CLAIM_LINE_FACT_KEY
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )
,[Ingenix Line Result IDs] =
   STUFF( ( 
		  SELECT 
		  '; ' + CAST( ICLR.INGENIX_CLAIM_LINE_RESULT_ID AS VARCHAR(50) )
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
				ON CLF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.dbo.INGENIX_CLAIM_LINE_RESULT AS ICLR
					ON ICLR.INGENIX_CLAIM_LINE_RESULT_KEY = CLF.INGENIX_CLAIM_LINE_RESULT_KEY

          WHERE
		  ClaimBilled.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CLF.CLAIM_LINE_FACT_KEY
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )
,[Ingenix Line Flag Actions] =
   STUFF( ( 
		  SELECT 
		  '; ' + CAST( IngenixFlag.FLAG_ACTION AS VARCHAR(50) )
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
				ON CLF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.dbo.INGNX_CLAIM_LINE_RES_TO_FLAGS AS ICLRTF
					ON ICLRTF.INGENIX_CLAIM_LINE_RESULT_KEY = CLF.INGENIX_CLAIM_LINE_RESULT_KEY

					LEFT JOIN wea_prod_dw.dbo.INGENIX_FLAG AS IngenixFlag
						ON IngenixFlag.INGENIX_FLAG_KEY = ICLRTF.INGENIX_FLAG_KEY

          WHERE
		  ClaimBilled.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CLF.CLAIM_LINE_FACT_KEY
		  ,ICLRTF.ReplIdentity
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )

,[Ingenix Line Flag Messages] =
   STUFF( ( 
		  SELECT 
		  '; ' + IngenixFlag.FLAG_MESSAGE
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
				ON CLF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.dbo.INGNX_CLAIM_LINE_RES_TO_FLAGS AS ICLRTF
					ON ICLRTF.INGENIX_CLAIM_LINE_RESULT_KEY = CLF.INGENIX_CLAIM_LINE_RESULT_KEY

					LEFT JOIN wea_prod_dw.dbo.INGENIX_FLAG AS IngenixFlag
						ON IngenixFlag.INGENIX_FLAG_KEY = ICLRTF.INGENIX_FLAG_KEY

          WHERE
		  ClaimBilled.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CLF.CLAIM_LINE_FACT_KEY
		  ,ICLRTF.ReplIdentity
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )

,[Ingenix Line Flag Mnemonics] =
   STUFF( ( 
		  SELECT 
		  '; ' + IngenixFlag.FLAG_MNEMONIC
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
				ON CLF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.dbo.INGNX_CLAIM_LINE_RES_TO_FLAGS AS ICLRTF
					ON ICLRTF.INGENIX_CLAIM_LINE_RESULT_KEY = CLF.INGENIX_CLAIM_LINE_RESULT_KEY

					LEFT JOIN wea_prod_dw.dbo.INGENIX_FLAG AS IngenixFlag
						ON IngenixFlag.INGENIX_FLAG_KEY = ICLRTF.INGENIX_FLAG_KEY

          WHERE
		  ClaimBilled.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CLF.CLAIM_LINE_FACT_KEY
		  ,ICLRTF.ReplIdentity
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )
,[Ingenix Line Flag Percents] =
   STUFF( ( 
		  SELECT 
		  '; ' + CAST( IngenixFlag.FLAG_PERCENT AS VARCHAR(50) )
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
				ON CLF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.dbo.INGNX_CLAIM_LINE_RES_TO_FLAGS AS ICLRTF
					ON ICLRTF.INGENIX_CLAIM_LINE_RESULT_KEY = CLF.INGENIX_CLAIM_LINE_RESULT_KEY

					LEFT JOIN wea_prod_dw.dbo.INGENIX_FLAG AS IngenixFlag
						ON IngenixFlag.INGENIX_FLAG_KEY = ICLRTF.INGENIX_FLAG_KEY

          WHERE
		  ClaimBilled.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CLF.CLAIM_LINE_FACT_KEY
		  ,ICLRTF.ReplIdentity
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )

FROM
#ClaimBilled AS ClaimBilled

	LEFT JOIN wea_prod_dw.dbo.CLAIM_FACT AS CF
		ON CF.CLAIM_FACT_KEY = ClaimBilled.CLAIM_FACT_KEY

		LEFT JOIN wea_prod_dw.dbo.INGENIX_CLAIM_RESULT AS ICR
			ON ICR.INGENIX_CLAIM_RESULT_KEY = CF.INGENIX_CLAIM_RESULT_KEY

),

#FirstIngenixLineResults AS (

SELECT
 IngenixResults.[Row Names]
,IngenixResults.[MEMBER ID]
,IngenixResults.[GROUP NUMBER]
,IngenixResults.[GROUP NAME]
,IngenixResults.[DATE OF SERVICE TO]
,IngenixResults.[DATE OF SERVICE FROM]
,IngenixResults.[PROVIDER NAME]
,IngenixResults.[CLAIM NUMBER]
,IngenixResults.[RECEIPT DATE]
,IngenixResults.[DOCUMENT TYPE]
,IngenixResults.[DOCUMENT SUBTYPE]
,IngenixResults.[LAST SEEN BY]
,IngenixResults.[DCN (Document ID)]
,IngenixResults.[Notes]
,IngenixResults.[VIP]
,IngenixResults.CLAIM_HCC_ID
,IngenixResults.CLAIM_FACT_KEY
,IngenixResults.[Adjudication Message Codes]
,IngenixResults.[Adjudication Message Descriptions] 
,IngenixResults.[First Adjudication Message Code]
,IngenixResults.[First Adjudication Message Description]
,IngenixResults.SUPPLIER_HCC_ID
,IngenixResults.SUPPLIER_NAME
,IngenixResults.TIN
,IngenixResults.TAX_NAME
,IngenixResults.[Billed Amounts on the Lines]
,IngenixResults.[Total Claim Billed]
,IngenixResults.[Ingenix Line Result Dispositions]
,IngenixResults.[Ingenix Line Result IDs]
,IngenixResults.[Ingenix Line Flag Actions]
,IngenixResults.[Ingenix Line Flag Messages]
,IngenixResults.[Ingenix Line Flag Mnemonics]
,IngenixResults.[Ingenix Line Flag Percents]
,[First Ingenix Line Disposition] =
	CASE
		WHEN CHARINDEX( ';', IngenixResults.[Ingenix Line Result Dispositions], 0 ) > 0 THEN REPLACE( LEFT( IngenixResults.[Ingenix Line Result Dispositions], CHARINDEX( ';', IngenixResults.[Ingenix Line Result Dispositions], 0 ) ), ';', '' )
		ELSE IngenixResults.[Ingenix Line Result Dispositions]
	END
,[First Ingenix Line ID] =
	CASE
		WHEN CHARINDEX( ';', IngenixResults.[Ingenix Line Result IDs], 0 ) > 0 THEN REPLACE( LEFT( IngenixResults.[Ingenix Line Result IDs], CHARINDEX( ';', IngenixResults.[Ingenix Line Result IDs], 0 ) ), ';', '' )
		ELSE IngenixResults.[Ingenix Line Result IDs]
	END
,[First Ingenix Line Flag Action] =
	CASE
		WHEN CHARINDEX( ';', IngenixResults.[Ingenix Line Flag Actions], 0 ) > 0 THEN REPLACE( LEFT( IngenixResults.[Ingenix Line Flag Actions], CHARINDEX( ';', IngenixResults.[Ingenix Line Flag Actions], 0 ) ), ';', '' )
		ELSE IngenixResults.[Ingenix Line Flag Actions]
	END
,[First Ingenix Line Flag Message] =
	CASE
		WHEN CHARINDEX( ';', IngenixResults.[Ingenix Line Flag Messages], 0 ) > 0 THEN REPLACE( LEFT( IngenixResults.[Ingenix Line Flag Messages], CHARINDEX( ';', IngenixResults.[Ingenix Line Flag Messages], 0 ) ), ';', '' )
		ELSE IngenixResults.[Ingenix Line Flag Messages]
	END
,[First Ingenix Line Flag Mnemonic] =
	CASE
		WHEN CHARINDEX( ';', IngenixResults.[Ingenix Line Flag Mnemonics], 0 ) > 0 THEN REPLACE( LEFT( IngenixResults.[Ingenix Line Flag Mnemonics], CHARINDEX( ';', IngenixResults.[Ingenix Line Flag Mnemonics], 0 ) ), ';', '' )
		ELSE IngenixResults.[Ingenix Line Flag Mnemonics]
	END
,[First Ingenix Line Flag Percent] =
	CASE
		WHEN CHARINDEX( ';', IngenixResults.[Ingenix Line Flag Percents], 0 ) > 0 THEN REPLACE( LEFT( IngenixResults.[Ingenix Line Flag Percents], CHARINDEX( ';', IngenixResults.[Ingenix Line Flag Percents], 0 ) ), ';', '' )
		ELSE IngenixResults.[Ingenix Line Flag Percents]
	END
FROM
#IngenixLineResults AS IngenixResults

),

#Providers AS (
SELECT
 FirstResults.[Row Names]
,FirstResults.[MEMBER ID]
,FirstResults.[GROUP NUMBER]
,FirstResults.[GROUP NAME]
,FirstResults.[DATE OF SERVICE TO]
,FirstResults.[DATE OF SERVICE FROM]
,FirstResults.[PROVIDER NAME]
,FirstResults.[CLAIM NUMBER]
,FirstResults.[RECEIPT DATE]
,FirstResults.[DOCUMENT TYPE]
,FirstResults.[DOCUMENT SUBTYPE]
,FirstResults.[LAST SEEN BY]
,FirstResults.[DCN (Document ID)]
,FirstResults.[Notes]
,FirstResults.[VIP]
,FirstResults.CLAIM_HCC_ID
,FirstResults.CLAIM_FACT_KEY
,FirstResults.[Adjudication Message Codes]
,FirstResults.[Adjudication Message Descriptions] 
,FirstResults.[First Adjudication Message Code]
,FirstResults.[First Adjudication Message Description]
,FirstResults.SUPPLIER_HCC_ID
,FirstResults.SUPPLIER_NAME
,FirstResults.TIN
,FirstResults.TAX_NAME
,FirstResults.[Billed Amounts on the Lines]
,FirstResults.[Total Claim Billed]
,FirstResults.[Ingenix Line Result Dispositions]
,FirstResults.[Ingenix Line Result IDs]
,FirstResults.[Ingenix Line Flag Actions]
,FirstResults.[Ingenix Line Flag Messages]
,FirstResults.[Ingenix Line Flag Mnemonics]
,FirstResults.[Ingenix Line Flag Percents]
,FirstResults.[First Ingenix Line Disposition]
,FirstResults.[First Ingenix Line ID]
,FirstResults.[First Ingenix Line Flag Action]
,FirstResults.[First Ingenix Line Flag Message]
,FirstResults.[First Ingenix Line Flag Mnemonic]
,FirstResults.[First Ingenix Line Flag Percent]
,[Referring Practitioner HCC ID] =
	ReferringPractitioner.PRACTITIONER_HCC_ID
,[Referring Practitioner NPI] =
	ReferringPractitioner.PRACTITIONER_NPI
,[Referring Practitioner Full Name] =
	ReferringPractitioner.PRACTITIONER_FULL_NAME
,[Claim Line Rendering Provider HCC IDs] =
   STUFF( ( 
		  SELECT 
		  '; ' + CAST( RenderingPractitioner.[PRACTITIONER_HCC_ID] AS VARCHAR(50) )
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
				ON CLF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.dbo.PRACTITIONER_HISTORY_FACT AS RenderingPractitioner
					ON RenderingPractitioner.PRACTITIONER_KEY = CLF.PRACTITIONER_KEY
					AND CF.STATEMENT_END_DATE_KEY BETWEEN RenderingPractitioner.VERSION_EFF_DATE_KEY AND RenderingPractitioner.VERSION_EXP_DATE_KEY - 1

          WHERE
		  FirstResults.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CLF.CLAIM_LINE_FACT_KEY
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )
,[Claim Line Rendering Provider NPIs] =
   STUFF( ( 
		  SELECT 
		  '; ' + CAST( RenderingPractitioner.[PRACTITIONER_NPI] AS VARCHAR(50) )
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
				ON CLF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.dbo.PRACTITIONER_HISTORY_FACT AS RenderingPractitioner
					ON RenderingPractitioner.PRACTITIONER_KEY = CLF.PRACTITIONER_KEY
					AND CF.STATEMENT_END_DATE_KEY BETWEEN RenderingPractitioner.VERSION_EFF_DATE_KEY AND RenderingPractitioner.VERSION_EXP_DATE_KEY - 1

          WHERE
		  FirstResults.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CLF.CLAIM_LINE_FACT_KEY
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )
,[Claim Line Rendering Provider Full Names] =
   STUFF( ( 
		  SELECT 
		  '; ' + CAST( RenderingPractitioner.[PRACTITIONER_FULL_NAME] AS VARCHAR(50) )
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_LINE_FACT AS CLF
				ON CLF.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.dbo.PRACTITIONER_HISTORY_FACT AS RenderingPractitioner
					ON RenderingPractitioner.PRACTITIONER_KEY = CLF.PRACTITIONER_KEY
					AND CF.STATEMENT_END_DATE_KEY BETWEEN RenderingPractitioner.VERSION_EFF_DATE_KEY AND RenderingPractitioner.VERSION_EXP_DATE_KEY - 1

          WHERE
		  FirstResults.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CLF.CLAIM_LINE_FACT_KEY
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )
,[Other Providers HCC IDs] =
   STUFF( ( 
		  SELECT 
		  '; ' + CAST( OtherPractitioner.[PRACTITIONER_HCC_ID] AS VARCHAR(50) )
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_FACT_TO_PRACTITIONER AS CF2P
				ON CF2P.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.dbo.PRACTITIONER_HISTORY_FACT AS OtherPractitioner
					ON OtherPractitioner.PRACTITIONER_KEY = CF2P.PRACTITIONER_KEY
					AND CF.STATEMENT_END_DATE_KEY BETWEEN OtherPractitioner.VERSION_EFF_DATE_KEY AND OtherPractitioner.VERSION_EXP_DATE_KEY - 1

          WHERE
		  FirstResults.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CF2P.SORT_ORDER
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )
,[Other Providers NPIs] =
   STUFF( ( 
		  SELECT 
		  '; ' + CAST( OtherPractitioner.[PRACTITIONER_NPI] AS VARCHAR(50) )
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_FACT_TO_PRACTITIONER AS CF2P
				ON CF2P.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.dbo.PRACTITIONER_HISTORY_FACT AS OtherPractitioner
					ON OtherPractitioner.PRACTITIONER_KEY = CF2P.PRACTITIONER_KEY
					AND CF.STATEMENT_END_DATE_KEY BETWEEN OtherPractitioner.VERSION_EFF_DATE_KEY AND OtherPractitioner.VERSION_EXP_DATE_KEY - 1

          WHERE
		  FirstResults.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CF2P.SORT_ORDER
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )
,[Other Providers Full Names] =
   STUFF( ( 
		  SELECT 
		  '; ' + CAST( OtherPractitioner.[PRACTITIONER_FULL_NAME] AS VARCHAR(50) )
          FROM
		  wea_prod_dw.dbo.CLAIM_FACT AS ClaimFact
			
			LEFT JOIN wea_prod_dw.dbo.CLAIM_FACT_TO_PRACTITIONER AS CF2P
				ON CF2P.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY

				LEFT JOIN wea_prod_dw.dbo.PRACTITIONER_HISTORY_FACT AS OtherPractitioner
					ON OtherPractitioner.PRACTITIONER_KEY = CF2P.PRACTITIONER_KEY
					AND CF.STATEMENT_END_DATE_KEY BETWEEN OtherPractitioner.VERSION_EFF_DATE_KEY AND OtherPractitioner.VERSION_EXP_DATE_KEY - 1

          WHERE
		  FirstResults.CLAIM_FACT_KEY = ClaimFact.CLAIM_FACT_KEY
          ORDER BY
		   CF2P.SORT_ORDER
          FOR XML PATH( '' ) 
		  )
		  , 1, 1, '' )
FROM
#FirstIngenixLineResults AS FirstResults

	LEFT JOIN wea_prod_dw.dbo.CLAIM_FACT AS CF
		ON CF.CLAIM_FACT_KEY = FirstResults.CLAIM_FACT_KEY

		LEFT JOIN wea_prod_dw.dbo.PRACTITIONER_HISTORY_FACT AS ReferringPractitioner
			ON ReferringPractitioner.PRACTITIONER_KEY = CF.REFERRING_PRACTITIONER_KEY
			AND CF.STATEMENT_END_DATE_KEY BETWEEN ReferringPractitioner.VERSION_EFF_DATE_KEY AND ReferringPractitioner.VERSION_EXP_DATE_KEY - 1

),

#FirstProviders AS (

SELECT
 Providers.[Row Names]
,Providers.[MEMBER ID]
,Providers.[GROUP NUMBER]
,Providers.[GROUP NAME]
,Providers.[DATE OF SERVICE TO]
,Providers.[DATE OF SERVICE FROM]
,Providers.[PROVIDER NAME]
,Providers.[CLAIM NUMBER]
,Providers.[RECEIPT DATE]
,Providers.[DOCUMENT TYPE]
,Providers.[DOCUMENT SUBTYPE]
,Providers.[LAST SEEN BY]
,Providers.[DCN (Document ID)]
,Providers.[Notes]
,Providers.[VIP]
,Providers.CLAIM_HCC_ID
,Providers.CLAIM_FACT_KEY
,Providers.[Adjudication Message Codes]
,Providers.[Adjudication Message Descriptions] 
,Providers.[First Adjudication Message Code]
,Providers.[First Adjudication Message Description]
,Providers.SUPPLIER_HCC_ID
,Providers.SUPPLIER_NAME
,Providers.TIN
,Providers.TAX_NAME
,Providers.[Billed Amounts on the Lines]
,Providers.[Total Claim Billed]
,Providers.[Ingenix Line Result Dispositions]
,Providers.[Ingenix Line Result IDs]
,Providers.[Ingenix Line Flag Actions]
,Providers.[Ingenix Line Flag Messages]
,Providers.[Ingenix Line Flag Mnemonics]
,Providers.[Ingenix Line Flag Percents]
,Providers.[First Ingenix Line Disposition]
,Providers.[First Ingenix Line ID]
,Providers.[First Ingenix Line Flag Action]
,Providers.[First Ingenix Line Flag Message]
,Providers.[First Ingenix Line Flag Mnemonic]
,Providers.[First Ingenix Line Flag Percent]
,Providers.[Referring Practitioner HCC ID]
,Providers.[Referring Practitioner NPI]
,Providers.[Referring Practitioner Full Name]
,Providers.[Claim Line Rendering Provider HCC IDs]
,Providers.[Claim Line Rendering Provider NPIs]
,Providers.[Claim Line Rendering Provider Full Names]
,Providers.[Other Providers HCC IDs]
,Providers.[Other Providers NPIs]
,Providers.[Other Providers Full Names]
,[First Claim Line Provider HCC ID] =
	CASE
		WHEN CHARINDEX( ';', Providers.[Claim Line Rendering Provider HCC IDs], 0 ) > 0 THEN REPLACE( LEFT( Providers.[Claim Line Rendering Provider HCC IDs], CHARINDEX( ';', Providers.[Claim Line Rendering Provider HCC IDs], 0 ) ), ';', '' )
		ELSE Providers.[Claim Line Rendering Provider HCC IDs]
	END
,[First Claim Line Provider NPI] =
	CASE
		WHEN CHARINDEX( ';', Providers.[Claim Line Rendering Provider NPIs], 0 ) > 0 THEN REPLACE( LEFT( Providers.[Claim Line Rendering Provider NPIs], CHARINDEX( ';', Providers.[Claim Line Rendering Provider NPIs], 0 ) ), ';', '' )
		ELSE Providers.[Claim Line Rendering Provider NPIs]
	END
,[First Claim Line Provider Full Name] =
	CASE
		WHEN CHARINDEX( ';', Providers.[Claim Line Rendering Provider Full Names], 0 ) > 0 THEN REPLACE( LEFT( Providers.[Claim Line Rendering Provider Full Names], CHARINDEX( ';', Providers.[Claim Line Rendering Provider Full Names], 0 ) ), ';', '' )
		ELSE Providers.[Claim Line Rendering Provider Full Names]
	END
,[First Other Provider HCC ID] =
	CASE
		WHEN CHARINDEX( ';', Providers.[Other Providers HCC IDs], 0 ) > 0 THEN REPLACE( LEFT( Providers.[Other Providers HCC IDs], CHARINDEX( ';', Providers.[Other Providers HCC IDs], 0 ) ), ';', '' )
		ELSE Providers.[Other Providers HCC IDs]
	END
,[First Other Provider NPI] =
	CASE
		WHEN CHARINDEX( ';', Providers.[Other Providers NPIs], 0 ) > 0 THEN REPLACE( LEFT( Providers.[Other Providers NPIs], CHARINDEX( ';', Providers.[Other Providers NPIs], 0 ) ), ';', '' )
		ELSE Providers.[Other Providers NPIs]
	END
,[First Other Provider Full Name] =
	CASE
		WHEN CHARINDEX( ';', Providers.[Other Providers Full Names], 0 ) > 0 THEN REPLACE( LEFT( Providers.[Other Providers Full Names], CHARINDEX( ';', Providers.[Other Providers Full Names], 0 ) ), ';', '' )
		ELSE Providers.[Other Providers Full Names]
	END
FROM
#Providers AS Providers

)

SELECT
 FirstProviders.[Row Names]
,FirstProviders.[MEMBER ID]
,FirstProviders.[GROUP NUMBER]
,FirstProviders.[GROUP NAME]
,FirstProviders.[DATE OF SERVICE TO]
,FirstProviders.[DATE OF SERVICE FROM]
,FirstProviders.[PROVIDER NAME]
,FirstProviders.[CLAIM NUMBER]
,FirstProviders.[RECEIPT DATE]
,FirstProviders.[DOCUMENT TYPE]
,FirstProviders.[DOCUMENT SUBTYPE]
,FirstProviders.[LAST SEEN BY]
,FirstProviders.[DCN (Document ID)]
,FirstProviders.[Notes]
,FirstProviders.[VIP]
,FirstProviders.CLAIM_HCC_ID
,FirstProviders.CLAIM_FACT_KEY
,[Adjudication Message Codes] =
	ISNULL( FirstProviders.[Adjudication Message Codes], '' )
,[Adjudication Message Descriptions] =
	ISNULL( FirstProviders.[Adjudication Message Descriptions] , '' )
,[First Adjudication Message Code] =
	ISNULL( FirstProviders.[First Adjudication Message Code], '' )
,[First Adjudication Message Description] =
	ISNULL( FirstProviders.[First Adjudication Message Description], '' )
,SUPPLIER_HCC_ID =
	ISNULL( FirstProviders.SUPPLIER_HCC_ID, '' )
,SUPPLIER_NAME =
	ISNULL( FirstProviders.SUPPLIER_NAME, '' )
,TIN =
	ISNULL( FirstProviders.TIN, '' )
,TAX_NAME =
	ISNULL( FirstProviders.TAX_NAME, '' )
,[Billed Amounts on the Lines] =
	ISNULL( FirstProviders.[Billed Amounts on the Lines], '' )
,[Total Claim Billed] =
	ISNULL( CAST( FirstProviders.[Total Claim Billed] AS VARCHAR(50) ), '' )
,[Ingenix Line Result Dispositions] =
	ISNULL( FirstProviders.[Ingenix Line Result Dispositions], '' )
,[Ingenix Line Result IDs] =
	ISNULL( FirstProviders.[Ingenix Line Result IDs], '' )
,[Ingenix Line Flag Actions] =
	ISNULL( FirstProviders.[Ingenix Line Flag Actions], '' )
,[Ingenix Line Flag Messages]  =
	ISNULL( FirstProviders.[Ingenix Line Flag Messages], '' )
,[Ingenix Line Flag Mnemonics] =
	ISNULL( FirstProviders.[Ingenix Line Flag Mnemonics], '' )
,[Ingenix Line Flag Percents] =
	ISNULL( FirstProviders.[Ingenix Line Flag Percents], '' )
,[First Ingenix Line Disposition] =
	ISNULL( FirstProviders.[First Ingenix Line Disposition], '' )
,[First Ingenix Line ID] =
	ISNULL( CAST( FirstProviders.[First Ingenix Line ID] AS VARCHAR(50) ), '' )
,[First Ingenix Line Flag Action] =
	ISNULL( FirstProviders.[First Ingenix Line Flag Action], '' )
,[First Ingenix Line Flag Message] =
	ISNULL( FirstProviders.[First Ingenix Line Flag Message], '' )
,[First Ingenix Line Flag Mnemonic] =
	ISNULL( FirstProviders.[First Ingenix Line Flag Mnemonic], '' )
,[First Ingenix Line Flag Percent] =
	ISNULL( CAST( FirstProviders.[First Ingenix Line Flag Percent] AS VARCHAR(50) ), '' )
,[Referring Practitioner HCC ID] =
	ISNULL( FirstProviders.[Referring Practitioner HCC ID], '' )
,[Referring Practitioner NPI] =
	ISNULL( FirstProviders.[Referring Practitioner NPI], '' )
,[Referring Practitioner Full Name] =
	ISNULL( FirstProviders.[Referring Practitioner Full Name], '' )
,[Claim Line Rendering Provider HCC IDs] =
	ISNULL( FirstProviders.[Claim Line Rendering Provider HCC IDs], '' )
,[Claim Line Rendering Provider NPIs] =
	ISNULL( FirstProviders.[Claim Line Rendering Provider NPIs], '' )
,[Claim Line Rendering Provider Full Names] =
	ISNULL( FirstProviders.[Claim Line Rendering Provider Full Names], '' )
,[Other Providers HCC IDs] =
	ISNULL( FirstProviders.[Other Providers HCC IDs], '' )
,[Other Providers NPIs] =
	ISNULL( FirstProviders.[Other Providers NPIs], '' )
,[Other Providers Full Names] =
	ISNULL( FirstProviders.[Other Providers Full Names], '' )
,[First Claim Line Provider HCC ID] =
	ISNULL( FirstProviders.[First Claim Line Provider HCC ID], '' )
,[First Claim Line Provider NPI] =
	ISNULL( CAST( FirstProviders.[First Claim Line Provider NPI] AS VARCHAR(50) ) , '' )
,[First Claim Line Provider Full Name] =
	ISNULL( FirstProviders.[First Claim Line Provider Full Name] , '' )
,[First Other Provider HCC ID] =
	ISNULL( FirstProviders.[First Other Provider HCC ID] , '' )
,[First Other Provider NPI] =
	ISNULL( CAST( FirstProviders.[First Other Provider NPI] AS VARCHAR(50) ), '' )
,[First Other Provider Full Name] =
	ISNULL( FirstProviders.[First Other Provider Full Name], '' )
INTO
[DEPT_Actuary_JMarx].[dbo].[BSR 29304 - OUTBOUND - Health Claims Additional Info]
FROM
#FirstProviders AS FirstProviders
ORDER BY
FirstProviders.[Row Names]

/* FOR DEBUGGING */  --SELECT * FROM [DEPT_Actuary_JMarx].[dbo].[BSR 29304 - OUTBOUND - Health Claims Additional Info]
END

GO
