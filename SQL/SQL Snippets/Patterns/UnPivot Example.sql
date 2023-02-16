/**************************************************************************************************************/
/*
You may want to read this before using UNPIVOT to determine if there are more efficient methods:
https://blog.devart.com/is-unpivot-the-best-way-for-converting-columns-into-rows.html
*/

/**************************************************************************************************************/
/* Convert original table fields to all be VARCHAR(MAX) */

IF OBJECT_ID( 'TEMPDB.DBO.#Test' ) IS NOT NULL
	BEGIN
		DROP TABLE #Test
	END;

CREATE TABLE #Test (
 [REC_ID]  VARCHAR(MAX)
,[VAACINE_GROUP]  VARCHAR(MAX)
,[CPT_CODE]  VARCHAR(MAX)
,[TRADE_NAME]  VARCHAR(MAX)
,[VACCINATION_DATE]  VARCHAR(MAX)
,[ADMINISTRATION_ROUTE_CODE]  VARCHAR(MAX)
,[BODY_SITE_CODE]  VARCHAR(MAX)
,[REACTION_CODE]  VARCHAR(MAX)
,[MANUFACTURE_CODE]  VARCHAR(MAX)
,[IMMUNIZATION_INFO_SOURCE]  VARCHAR(MAX)
,[LOT_NUM]  VARCHAR(MAX)
,[PROVIDER_NAME]  VARCHAR(MAX)
,[ADMINISTERED_BY_NAME]  VARCHAR(MAX)
,[SITE_NAME]  VARCHAR(MAX)
,[SENDING_ORGANIZATION]  VARCHAR(MAX)
,[SENT_FLAG]  VARCHAR(MAX)
,[CLAIM_FACT_KEY]  VARCHAR(MAX)
,[CLAIM_LINE_FACT_KEY]  VARCHAR(MAX)
,[CREATED_BY]  VARCHAR(MAX)
,[CREATED_DATE]  VARCHAR(MAX)
,[MODIFIED_BY]  VARCHAR(MAX)
,[MODIFIED_DATE]  VARCHAR(MAX)
);

INSERT INTO #Test
SELECT TOP 20
 REC_ID
,VAACINE_GROUP
,CPT_CODE
,TRADE_NAME
,VACCINATION_DATE
,ADMINISTRATION_ROUTE_CODE
,BODY_SITE_CODE
,REACTION_CODE
,MANUFACTURE_CODE
,IMMUNIZATION_INFO_SOURCE
,LOT_NUM
,PROVIDER_NAME
,ADMINISTERED_BY_NAME
,SITE_NAME
,SENDING_ORGANIZATION
,SENT_FLAG
,CLAIM_FACT_KEY
,CLAIM_LINE_FACT_KEY
,CREATED_BY
,CREATED_DATE
,MODIFIED_BY
,MODIFIED_DATE
FROM
WEA_EDW.OUTBOUND.WI_IMMUN_CLAIM_PERSISTED

/**************************************************************************************************************/
/* Original table */

SELECT TOP 0 [Sample Of Original Table] = NULL

SELECT * FROM #Test

/**************************************************************************************************************/
/* Unpivot all columns */

SELECT TOP 0 [Sample Unpivoted Table Output - All Columns] = NULL

SELECT
 ColumnName
,[Value]
FROM
#Test
UNPIVOT (
    [Value]
    FOR ColumnName IN ( 
			REC_ID
			,VAACINE_GROUP
			,CPT_CODE
			,TRADE_NAME
			,VACCINATION_DATE
			,ADMINISTRATION_ROUTE_CODE
			,BODY_SITE_CODE
			,REACTION_CODE
			,MANUFACTURE_CODE
			,IMMUNIZATION_INFO_SOURCE
			,LOT_NUM
			,PROVIDER_NAME
			,ADMINISTERED_BY_NAME
			,SITE_NAME
			,SENDING_ORGANIZATION
			,SENT_FLAG
			,CLAIM_FACT_KEY
			,CLAIM_LINE_FACT_KEY
			,CREATED_BY
			,CREATED_DATE
			,MODIFIED_BY
			,MODIFIED_DATE
	)
) AS Unpivoted

/**************************************************************************************************************/
/* Unpivot while retaining the record id */

SELECT TOP 0 [Sample Unpivoted Table Output - All Columns except ID] = NULL

SELECT
 REC_ID
,ColumnName
,[Value]
FROM
#Test
UNPIVOT (
    [Value]
    FOR ColumnName IN ( 
			--REC_ID
			VAACINE_GROUP
			,CPT_CODE
			,TRADE_NAME
			,VACCINATION_DATE
			,ADMINISTRATION_ROUTE_CODE
			,BODY_SITE_CODE
			,REACTION_CODE
			,MANUFACTURE_CODE
			,IMMUNIZATION_INFO_SOURCE
			,LOT_NUM
			,PROVIDER_NAME
			,ADMINISTERED_BY_NAME
			,SITE_NAME
			,SENDING_ORGANIZATION
			,SENT_FLAG
			,CLAIM_FACT_KEY
			,CLAIM_LINE_FACT_KEY
			,CREATED_BY
			,CREATED_DATE
			,MODIFIED_BY
			,MODIFIED_DATE
	)
) AS Unpivoted
