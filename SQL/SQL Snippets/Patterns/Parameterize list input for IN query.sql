/* Only useful for SQL Server 2016+ (Compatability level 130 )

https://database.guide/how-to-check-a-databases-compatibility-level-in-sql-server-using-t-sql/

SELECT name, compatibility_level
FROM sys.databases;

*/

/**************************************************************************************************************/
/* Define codes to be looked up */

DECLARE
@TriggerCodes		NVARCHAR(MAX)	= '202,203';

/**************************************************************************************************************/
/* Create Temp Table of codes to be looked up */

IF OBJECT_ID( 'TEMPDB.DBO.#LookupTriggers' ) IS NOT NULL
	BEGIN
		DROP TABLE #LookupTriggers
	END;

CREATE TABLE #LookupTriggers(
[Trigger Codes] NVARCHAR(120)
);

INSERT INTO #LookupTriggers
SELECT
StringSplit.[value]
FROM
STRING_SPLIT(@TriggerCodes, ',') AS StringSplit;

/* FOR DEBUGGING */  --SELECT * FROM #LookupTriggers

/**************************************************************************************************************/
/* Use the lookup codes in the query */

SELECT
ClaimReviewRepairTrigger.*
FROM
wea_prod_dw.dbo.REVIEW_REPAIR_TRIGGER AS ClaimReviewRepairTrigger

	JOIN #LookupTriggers
		ON	#LookupTriggers.[Trigger Codes] = ClaimReviewRepairTrigger.TRIGGER_CODE

WHERE
1 = 1

--OR

SELECT
ClaimReviewRepairTrigger.*
FROM
wea_prod_dw.dbo.REVIEW_REPAIR_TRIGGER AS ClaimReviewRepairTrigger
WHERE
ClaimReviewRepairTrigger.TRIGGER_CODE IN ( SELECT [Trigger Codes] FROM #LookupTriggers )

--OR

SELECT
ClaimReviewRepairTrigger.*
FROM
wea_prod_dw.dbo.REVIEW_REPAIR_TRIGGER AS ClaimReviewRepairTrigger
WHERE
ClaimReviewRepairTrigger.TRIGGER_CODE IN ( SELECT [Value] FROM STRING_SPLIT( @TriggerCodes, ',') )
