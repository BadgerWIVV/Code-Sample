/**************************************************************************/
/* DECLARE PARAMETERS */

DECLARE
 @Date_Parameter						DATE = '2020-01-01'
,@Date_Key								NUMERIC( 19,0 )
,@Current_Date_Key						NUMERIC( 19,0 )
,@Date_Parameter2						DATE = '2019-09-30'
,@Date_Key2								NUMERIC( 19,0 );

/*******************************************************************************/
/* SET PARAMETERS */
/*******************************************************************************/
/* FIND THE DATE_KEY ASSOCIATED TO THE Current Date. THIS WILL BE USED TO FIND MEMBER AND ACCOUNT INFORMATION */


SET @Current_Date_Key = (
SELECT
DATE_KEY
FROM
wea_prod_dw.dbo.DATE_DIMENSION
WHERE
DATE_VALUE = CAST( GETDATE() AS DATE )

);

/*******************************************************************************/
/* FIND THE DATE_KEY ASSOCIATED TO THE 1st Date Parameter. THIS WILL BE USED TO FIND MEMBER AND ACCOUNT INFORMATION */

SET @Date_Key = (
SELECT
DATE_KEY
FROM
wea_prod_dw.dbo.DATE_DIMENSION
WHERE
DATE_VALUE = @Date_Parameter

);

/*******************************************************************************/
/* FIND THE DATE_KEY ASSOCIATED TO 2nd Date Parameter. THIS WILL BE USED TO FIND MEMBER AND ACCOUNT INFORMATION */

SET @Date_Key2 = (
SELECT
DATE_KEY
FROM
wea_prod_dw.dbo.DATE_DIMENSION
WHERE
DATE_VALUE = @Date_Parameter2

);

/*******************************************************************************/
/* FIND MEMBERs ON Current Date*/

SELECT TOP 1 [Query] = 'Current Membership';

SELECT
 [Company] =
	CASE
		WHEN tac.ACCOUNT_TYPE_DESC LIKE '%Commercial' THEN 'HT'
		ELSE 'WEA'
	END
,tac.ACCOUNT_TYPE_DESC
,ta.ACCOUNT_HCC_ID
,TA.ACCOUNT_NAME
,A.ACCOUNT_HCC_ID
,A.ACCOUNT_NAME
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
ta.ACCOUNT_HCC_ID IN ( '32001', '32002' )
AND
m.MEMBER_STATUS = 'a'

/*******************************************************************************/
/* FIND MEMBER ON Date Parameter 1*/

SELECT TOP 1 [Query] = 'Membership On Date Parameter 1';

SELECT
 [Company] =
	CASE
		WHEN tac.ACCOUNT_TYPE_DESC LIKE '%Commercial' THEN 'HT'
		ELSE 'WEA'
	END
,tac.ACCOUNT_TYPE_DESC
,ta.ACCOUNT_HCC_ID
,TA.ACCOUNT_NAME
,A.ACCOUNT_HCC_ID
,A.ACCOUNT_NAME
,m.MEMBER_HCC_ID
,m.MEMBER_STATUS
,[Date Parameter] =
	@Date_Parameter
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
ta.ACCOUNT_HCC_ID IN ( '32001', '32002' )
AND
m.MEMBER_STATUS = 'a'


/*******************************************************************************/
/* FIND MEMBER ON Date Parameter 2 */

SELECT TOP 1 [Query] = 'Membership On Date Parameter 2';

SELECT
 [Company] =
	CASE
		WHEN tac.ACCOUNT_TYPE_DESC LIKE '%Commercial' THEN 'HT'
		ELSE 'WEA'
	END
,tac.ACCOUNT_TYPE_DESC
,ta.ACCOUNT_HCC_ID
,TA.ACCOUNT_NAME
,A.ACCOUNT_HCC_ID
,A.ACCOUNT_NAME
,m.MEMBER_HCC_ID
,m.MEMBER_STATUS
,[Date Parameter] =
	@Date_Parameter2
FROM
wea_prod_dw.dbo.member_history_fact AS m

	JOIN wea_prod_dw.dbo.account_history_fact as a
		ON a.account_key = m.account_key

		JOIN wea_prod_dw.dbo.account_history_fact as ta
			ON ta.account_key = a.top_account_key

			JOIN wea_prod_dw.dbo.account_type_code AS tac
				ON tac.ACCOUNT_TYPE_KEY = ta.ACCOUNT_TYPE_KEY

WHERE
@Date_Key2 BETWEEN m.VERSION_EFF_DATE_KEY AND m.VERSION_EXP_DATE_KEY - 1
AND
@Date_Key2 BETWEEN a.VERSION_EFF_DATE_KEY AND a.VERSION_EXP_DATE_KEY - 1
AND
@Date_Key2 BETWEEN ta.VERSION_EFF_DATE_KEY AND ta.VERSION_EXP_DATE_KEY - 1
AND
ta.ACCOUNT_HCC_ID IN ( '32001', '32002' )
AND
m.MEMBER_STATUS = 'a'