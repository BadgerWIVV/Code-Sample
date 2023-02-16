DECLARE
 @CategoryNameContains	VARCHAR(1000) = 'General Services (Auth) - 2';

SELECT DISTINCT
ServiceCategory.SERVICE_CATEGORY_NAME
FROM
[wea_prod_dw].[dbo].[SERVICE_CATEGORY_HIST_FACT] AS ServiceCategory

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS ServiceCategoryVersionEffectiveDate
		ON ServiceCategoryVersionEffectiveDate.DATE_KEY = ServiceCategory.VERSION_EFF_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS ServiceCategoryVersionExpirationDate
		ON ServiceCategoryVersionExpirationDate.DATE_KEY = ServiceCategory.VERSION_EXP_DATE_KEY

	LEFT JOIN [wea_prod_dw].[dbo].[SERVICE_CATEGORY_TYPE_CODE] AS ServiceCategoryType
		ON ServiceCategoryType.SERVICE_CATEGORY_TYPE_CODE = ServiceCategory.SERVICE_CATEGORY_TYPE_CODE

	LEFT JOIN [wea_prod_dw].[dbo].[SERV_CATEGORY_X_SERV_CD_RANGE]  AS Bridge
		ON Bridge.SERVICE_CATEGORY_HIST_FACT_KEY = ServiceCategory.SERVICE_CATEGORY_HIST_FACT_KEY

		LEFT JOIN [wea_prod_dw].[dbo].[SERVICE_CODE_RANGE_FACT] AS Codes
			ON Codes.SERVICE_CODE_RANGE_FACT_KEY = Bridge.SERVICE_CODE_RANGE_FACT_KEY

WHERE
1 = 1
--AND
--SERVICE_CATEGORY_KEY = '137'
AND
ServiceCategory.SERVICE_CATEGORY_NAME LIKE '%' + @CategoryNameContains + '%'
AND
ServiceCategoryVersionExpirationDate.DATE_VALUE > GETDATE()
AND
ServiceCategoryVersionEffectiveDate.DATE_VALUE <= GETDATE()

SELECT TOP (1000) 
 ServiceCategory.[SERVICE_CATEGORY_HIST_FACT_KEY]
,ServiceCategory.[SERVICE_CATEGORY_KEY]
,ServiceCategory.[SERVICE_CATEGORY_NAME]
,ServiceCategory.[DEFINITION]
,ServiceCategory.[DESCRIPTION]
,ServiceCategory.[SHOW_IN_PORTAL]
,ServiceCategory.[SERVICE_CATEGORY_STATUS]
--,ServiceCategory.[SERVICE_CATEGORY_TYPE_CODE]
,ServiceCategory.[AUDIT_LOG_KEY]
--,ServiceCategory.[SERVICE_CAT_HISTORY_FACT_COUNT]
,ServiceCategory.[VERSION_EFF_DATE_KEY]
,[Version Effective Date] =
	ServiceCategoryVersionEffectiveDate.DATE_VALUE
,ServiceCategory.[VERSION_EXP_DATE_KEY]
,[Version Expiration Date] =
	ServiceCategoryVersionExpirationDate.DATE_VALUE
,ServiceCategoryType.SERVICE_CATEGORY_TYPE_NAME
,Bridge.[SERVICE_CATEGORY_HIST_FACT_KEY]
,Bridge.[SERVICE_CODE_RANGE_FACT_KEY]
,Bridge.[ReplIdentity]
,Codes.*
FROM
[wea_prod_dw].[dbo].[SERVICE_CATEGORY_HIST_FACT] AS ServiceCategory

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS ServiceCategoryVersionEffectiveDate
		ON ServiceCategoryVersionEffectiveDate.DATE_KEY = ServiceCategory.VERSION_EFF_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS ServiceCategoryVersionExpirationDate
		ON ServiceCategoryVersionExpirationDate.DATE_KEY = ServiceCategory.VERSION_EXP_DATE_KEY

	LEFT JOIN [wea_prod_dw].[dbo].[SERVICE_CATEGORY_TYPE_CODE] AS ServiceCategoryType
		ON ServiceCategoryType.SERVICE_CATEGORY_TYPE_CODE = ServiceCategory.SERVICE_CATEGORY_TYPE_CODE

	LEFT JOIN [wea_prod_dw].[dbo].[SERV_CATEGORY_X_SERV_CD_RANGE]  AS Bridge
		ON Bridge.SERVICE_CATEGORY_HIST_FACT_KEY = ServiceCategory.SERVICE_CATEGORY_HIST_FACT_KEY

		LEFT JOIN [wea_prod_dw].[dbo].[SERVICE_CODE_RANGE_FACT] AS Codes
			ON Codes.SERVICE_CODE_RANGE_FACT_KEY = Bridge.SERVICE_CODE_RANGE_FACT_KEY

WHERE
1 = 1
--AND
--SERVICE_CATEGORY_KEY = '137'
AND
ServiceCategory.SERVICE_CATEGORY_NAME LIKE '%' + @CategoryNameContains + '%'
AND
ServiceCategoryVersionExpirationDate.DATE_VALUE > GETDATE()
AND
ServiceCategoryVersionEffectiveDate.DATE_VALUE <= GETDATE()

/**************************************************************************************************************/
/* Search the definition for expression */

DECLARE
 @CategoryDefinitionContains	VARCHAR(1000) = '96127';

SELECT DISTINCT
ServiceCategory.SERVICE_CATEGORY_NAME
FROM
[wea_prod_dw].[dbo].[SERVICE_CATEGORY_HIST_FACT] AS ServiceCategory

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS ServiceCategoryVersionEffectiveDate
		ON ServiceCategoryVersionEffectiveDate.DATE_KEY = ServiceCategory.VERSION_EFF_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS ServiceCategoryVersionExpirationDate
		ON ServiceCategoryVersionExpirationDate.DATE_KEY = ServiceCategory.VERSION_EXP_DATE_KEY


	LEFT JOIN [wea_prod_dw].[dbo].[SERVICE_CATEGORY_TYPE_CODE] AS ServiceCategoryType
		ON ServiceCategoryType.SERVICE_CATEGORY_TYPE_CODE = ServiceCategory.SERVICE_CATEGORY_TYPE_CODE

	LEFT JOIN [wea_prod_dw].[dbo].[SERV_CATEGORY_X_SERV_CD_RANGE]  AS Bridge
		ON Bridge.SERVICE_CATEGORY_HIST_FACT_KEY = ServiceCategory.SERVICE_CATEGORY_HIST_FACT_KEY

		LEFT JOIN [wea_prod_dw].[dbo].[SERVICE_CODE_RANGE_FACT] AS Codes
			ON Codes.SERVICE_CODE_RANGE_FACT_KEY = Bridge.SERVICE_CODE_RANGE_FACT_KEY

WHERE
1 = 1
--AND
--SERVICE_CATEGORY_KEY = '137'
AND
ServiceCategory.[DEFINITION] LIKE '%' + @CategoryDefinitionContains + '%'
AND
ServiceCategoryVersionExpirationDate.DATE_VALUE > GETDATE()
AND
ServiceCategoryVersionEffectiveDate.DATE_VALUE <= GETDATE()

SELECT TOP (1000) 
 ServiceCategory.[SERVICE_CATEGORY_HIST_FACT_KEY]
,ServiceCategory.[SERVICE_CATEGORY_KEY]
,ServiceCategory.[SERVICE_CATEGORY_NAME]
,ServiceCategory.[DEFINITION]
,ServiceCategory.[DESCRIPTION]
,ServiceCategory.[SHOW_IN_PORTAL]
,ServiceCategory.[SERVICE_CATEGORY_STATUS]
--,ServiceCategory.[SERVICE_CATEGORY_TYPE_CODE]
,ServiceCategory.[AUDIT_LOG_KEY]
--,ServiceCategory.[SERVICE_CAT_HISTORY_FACT_COUNT]
,ServiceCategory.[VERSION_EFF_DATE_KEY]
,[Version Effective Date] =
	ServiceCategoryVersionEffectiveDate.DATE_VALUE
,ServiceCategory.[VERSION_EXP_DATE_KEY]
,[Version Expiration Date] =
	ServiceCategoryVersionExpirationDate.DATE_VALUE
,ServiceCategoryType.SERVICE_CATEGORY_TYPE_NAME
,Bridge.[SERVICE_CATEGORY_HIST_FACT_KEY]
,Bridge.[SERVICE_CODE_RANGE_FACT_KEY]
,Bridge.[ReplIdentity]
,Codes.*
FROM
[wea_prod_dw].[dbo].[SERVICE_CATEGORY_HIST_FACT] AS ServiceCategory

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS ServiceCategoryVersionEffectiveDate
		ON ServiceCategoryVersionEffectiveDate.DATE_KEY = ServiceCategory.VERSION_EFF_DATE_KEY

	LEFT JOIN wea_prod_dw.dbo.DATE_DIMENSION AS ServiceCategoryVersionExpirationDate
		ON ServiceCategoryVersionExpirationDate.DATE_KEY = ServiceCategory.VERSION_EXP_DATE_KEY


	LEFT JOIN [wea_prod_dw].[dbo].[SERVICE_CATEGORY_TYPE_CODE] AS ServiceCategoryType
		ON ServiceCategoryType.SERVICE_CATEGORY_TYPE_CODE = ServiceCategory.SERVICE_CATEGORY_TYPE_CODE

	LEFT JOIN [wea_prod_dw].[dbo].[SERV_CATEGORY_X_SERV_CD_RANGE]  AS Bridge
		ON Bridge.SERVICE_CATEGORY_HIST_FACT_KEY = ServiceCategory.SERVICE_CATEGORY_HIST_FACT_KEY

		LEFT JOIN [wea_prod_dw].[dbo].[SERVICE_CODE_RANGE_FACT] AS Codes
			ON Codes.SERVICE_CODE_RANGE_FACT_KEY = Bridge.SERVICE_CODE_RANGE_FACT_KEY

WHERE
1 = 1
--AND
--SERVICE_CATEGORY_KEY = '137'
AND
ServiceCategory.[DEFINITION] LIKE '%' + @CategoryDefinitionContains + '%'
AND
ServiceCategoryVersionExpirationDate.DATE_VALUE > GETDATE()
AND
ServiceCategoryVersionEffectiveDate.DATE_VALUE <= GETDATE()

/**************************************************************************************************************/
/* OBSERVE WHERE SERVICE CATEGORIES CAN BE FOUND IN DATABASE 
	- CURRENTLY CANNOT FIND A LINK TO CLAIMS 
	- THE PRIMARY KEYS ARE ONLY FOUND IN THE TWO TABLES...NO BRIDGE TABLES, NO DIMENSIONS IN OTHER FACT TABLES.
*/

/*

USE wea_prod_dw;
GO

SELECT
*
FROM
INFORMATION_SCHEMA.COLUMNS
WHERE
1 = 1

AND TABLE_NAME IN ( 'SERV_CATEGORY_X_SERV_CD_RANGE', 'SERVICE_CATEGORY_HIST_FACT' )
--AND TABLE_SCHEMA = ''
--AND COLUMN_NAME = 'SERVICE_CATEGORY_HIST_FACT_KEY'



USE wea_prod_dw;
GO

SELECT
*
FROM
INFORMATION_SCHEMA.COLUMNS
WHERE
1 = 1

--AND TABLE_NAME = ''
--AND TABLE_SCHEMA = ''
AND COLUMN_NAME IN ( 'SERVICE_CATEGORY_HIST_FACT_KEY', 'SERVICE_CATEGORY_KEY' )

*/