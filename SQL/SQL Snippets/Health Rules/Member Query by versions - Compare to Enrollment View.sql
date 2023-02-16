/**************************************************************************/
/* DECLARE PARAMETERS */

DECLARE
 @Date_Parameter						DATE			= '2019-05-07'
,@Date_Key								NUMERIC( 19,0 )
,@Current_Date_Key						NUMERIC( 19,0 )
,@MemberHccID							VARCHAR(30)		=	''
,@TopAccountHccID						VARCHAR(30)		=	''
;

/*******************************************************************************/
/* SET PARAMETERS */
/*******************************************************************************/
/* FIND THE DATE_KEY ASSOCIATED TO THE 15TH OF SEPTEMBER. THIS WILL BE USED TO FIND MEMBER AND ACCOUNT INFORMATION */

SET @Date_Key = (
SELECT
DATE_KEY
FROM
wea_prod_dw.dbo.DATE_DIMENSION
WHERE
DATE_VALUE = @Date_Parameter

);

SET @Current_Date_Key = (
SELECT
DATE_KEY
FROM
wea_prod_dw.dbo.DATE_DIMENSION
WHERE
DATE_VALUE = CAST( GETDATE() AS DATE )

);

/*******************************************************************************/
/* FIND MEMBER ON 5-7 */

SELECT
 [Company] =
	CASE
		WHEN tac.ACCOUNT_TYPE_DESC LIKE '%Commercial' THEN 'HT'
		ELSE 'WEA'
	END
,tac.ACCOUNT_TYPE_DESC
,ta.ACCOUNT_HCC_ID
,TA.ACCOUNT_NAME
,m.MEMBER_HCC_ID
,m.MEMBER_STATUS
FROM
wea_prod_dw.dbo.member_history_fact AS m

	JOIN wea_prod_dw.dbo.account_history_fact as a
		ON a.account_key = m.account_key

		JOIN wea_prod_dw.dbo.account_history_fact as ta
			ON ta.account_key = a.top_account_key

			JOIN wea_prod_dw.dbo.account_type_code AS tac
				ON tac.ACCOUNT_TYPE_KEY = ta.ACCOUNT_TYPE_KEY

WHERE
@Current_Date_Key BETWEEN m.VERSION_EFF_DATE_KEY AND m.VERSION_EXP_DATE_KEY - 1
AND
@Current_Date_Key BETWEEN a.VERSION_EFF_DATE_KEY AND a.VERSION_EXP_DATE_KEY - 1
AND
@Current_Date_Key BETWEEN ta.VERSION_EFF_DATE_KEY AND ta.VERSION_EXP_DATE_KEY - 1
AND
m.MEMBER_HCC_ID = @MemberHccID
AND
ta.ACCOUNT_HCC_ID = @TopAccountHccID

/*******************************************************************************/
/* FIND MEMBER ON 5-7 */

SELECT
 [Company] =
	CASE
		WHEN tac.ACCOUNT_TYPE_DESC LIKE '%Commercial' THEN 'HT'
		ELSE 'WEA'
	END
,tac.ACCOUNT_TYPE_DESC
,ta.ACCOUNT_HCC_ID
,TA.ACCOUNT_NAME
,m.MEMBER_HCC_ID
,m.MEMBER_STATUS
FROM
wea_prod_dw.dbo.member_history_fact AS m

	JOIN wea_prod_dw.dbo.account_history_fact as a
		ON a.account_key = m.account_key

		JOIN wea_prod_dw.dbo.account_history_fact as ta
			ON ta.account_key = a.top_account_key

			JOIN wea_prod_dw.dbo.account_type_code AS tac
				ON tac.ACCOUNT_TYPE_KEY = ta.ACCOUNT_TYPE_KEY

WHERE
@Date_Key BETWEEN m.VERSION_EFF_DATE_KEY AND m.VERSION_EXP_DATE_KEY - 1
AND
@Date_Key BETWEEN a.VERSION_EFF_DATE_KEY AND a.VERSION_EXP_DATE_KEY - 1
AND
@Date_Key BETWEEN ta.VERSION_EFF_DATE_KEY AND ta.VERSION_EXP_DATE_KEY - 1
AND
m.MEMBER_HCC_ID = @MemberHccID
AND
ta.ACCOUNT_HCC_ID = @TopAccountHccID

/*******************************************************************************/
/* FIND MEMBER FROM ENROLLMENT VIEW */
select 
       [MEMBER_HCC_ID]
       , [MEMBER_FULL_NAME]
       , [BENEFIT_PLAN_HCC_ID_1]
       , [BENEFIT_PLAN_NAME_1]
       , [VER_EFF_DATE]
       ,[TERMINATION_DATE]
	   ,*
from 
       [BISQLPD\DW].[wea_prod_dw].dbo.enrollment
where 
       [BENEFIT_PLAN_HCC_ID_1] like '%' + @TopAccountHccID + '%' 
       and [MEMBER_HCC_ID] = @MemberHccID


/*******************************************************************************/
/* FIND ANY MEMBER INFORMATION ON THIS MEMBER */

SELECT
 [Company] =
	CASE
		WHEN tac.ACCOUNT_TYPE_DESC LIKE '%Commercial' THEN 'HT'
		ELSE 'WEA'
	END
,tac.ACCOUNT_TYPE_DESC
,[Top Account HCC ID] =
	ta.ACCOUNT_HCC_ID
,[Top Account Name] =
	TA.ACCOUNT_NAME

,[Account Version Effective Date] =
	AccountVersionEffectiveDate.DATE_VALUE
,[Account Version Termination Date] =
	AccountVersionTerminationDate.DATE_VALUE
,[Account Current Version Status] =
	CASE
		WHEN @Current_Date_Key BETWEEN AccountVersionEffectiveDate.DATE_KEY AND  AccountVersionTerminationDate.DATE_KEY - 1 THEN 'Current'
		ELSE 'Not Current'
	END
,[Account Version Status As of Date Parameter] =
	CASE
		WHEN @Date_Key BETWEEN AccountVersionEffectiveDate.DATE_KEY AND  AccountVersionTerminationDate.DATE_KEY - 1 THEN 'Active Version As Of The Date Parameter'
		ELSE 'Not Current'
	END

,m.MEMBER_HCC_ID
,m.MEMBER_STATUS
,[Member Effective Date] =
	MemberEffectiveDate.DATE_VALUE
,[Member Termination Date] =
	MemberTerminationDate.DATE_VALUE
,[Member Version Effective Date] =
	MemberVersionEffectiveDate.DATE_VALUE
,[Member Version Termination Date] =
	MemberVersionTerminationDate.DATE_VALUE
,[Member Current Version Status] =
	CASE
		WHEN @Current_Date_Key BETWEEN MemberVersionEffectiveDate.DATE_KEY AND  MemberVersionTerminationDate.DATE_KEY - 1 THEN 'Current'
		ELSE 'Not Current'
	END
,[Member Version Status As of Date Parameter] =
	CASE
		WHEN @Date_Key BETWEEN MemberVersionEffectiveDate.DATE_KEY AND  MemberVersionTerminationDate.DATE_KEY - 1 THEN 'Active Version As Of The Date Parameter'
		ELSE 'Not Current'
	END
FROM
wea_prod_dw.dbo.member_history_fact AS m

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS MemberEffectiveDate
		ON MemberEffectiveDate.DATE_KEY = M.MEMBER_EFFECTIVE_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS MemberTerminationDate
		ON MemberTerminationDate.DATE_KEY = M.MEMBER_TERMINATION_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS MemberVersionEffectiveDate
		ON MemberVersionEffectiveDate.DATE_KEY = M.VERSION_EFF_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS MemberVersionTerminationDate
		ON MemberVersionTerminationDate.DATE_KEY = M.VERSION_EXP_DATE_KEY

	JOIN wea_prod_dw.dbo.account_history_fact as a
		ON a.account_key = m.account_key

		LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS AccountVersionEffectiveDate
			ON AccountVersionEffectiveDate.DATE_KEY = a.VERSION_EFF_DATE_KEY

		LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS AccountVersionTerminationDate
			ON AccountVersionTerminationDate.DATE_KEY = a.VERSION_EXP_DATE_KEY

		JOIN wea_prod_dw.dbo.account_history_fact as ta
			ON ta.account_key = a.top_account_key

			JOIN wea_prod_dw.dbo.account_type_code AS tac
				ON tac.ACCOUNT_TYPE_KEY = ta.ACCOUNT_TYPE_KEY

WHERE
m.MEMBER_HCC_ID = @MemberHccID
AND
ta.ACCOUNT_HCC_ID = @TopAccountHccID
