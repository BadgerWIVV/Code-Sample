/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000)
 ClaimLine.[CLAIM_LINE_FACT_KEY]
,ClaimLine.[REVIEW_REPAIR_TRIGGER_KEY]
,ClaimLine.[ReplIdentity]
,ReviewRepairTrigger.*
FROM
[wea_prod_dw].[dbo].[CLAIM_LN_FCT_TO_REVIEW_TRIGGER] AS ClaimLine

	JOIN [wea_prod_dw].[dbo].[REVIEW_REPAIR_TRIGGER] AS ReviewRepairTrigger
		ON	ReviewRepairTrigger.REVIEW_REPAIR_TRIGGER_KEY = ClaimLine.REVIEW_REPAIR_TRIGGER_KEY


SELECT TOP (1000)
 Claim.[CLAIM_FACT_KEY]
,Claim.[REVIEW_REPAIR_TRIGGER_KEY]
,Claim.[ReplIdentity]
,ReviewRepairTrigger.*
FROM
[wea_prod_dw].[dbo].[CLAIM_FACT_TO_REVIEW_TRIGGER] AS Claim

	JOIN [wea_prod_dw].[dbo].[REVIEW_REPAIR_TRIGGER] AS ReviewRepairTrigger
		ON	ReviewRepairTrigger.REVIEW_REPAIR_TRIGGER_KEY = Claim.REVIEW_REPAIR_TRIGGER_KEY

WHERE
IS_EXPIRED NOT IN ( 'U' )