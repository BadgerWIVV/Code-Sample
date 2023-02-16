/**************************************************************************************************************/
/* FOR QA */

IF OBJECT_ID( 'TEMPDB.DBO.#LineDups' ) IS NOT NULL DROP TABLE #LineDups;

SELECT
 CLAIM_HCC_ID
,CLAIM_LINE_HCC_ID
,[Row Count] =
	COUNT( * )
INTO
#LineDups
FROM
WEA.DN.MEDICAL_CLAIMS_VIEW
GROUP BY
 CLAIM_HCC_ID
,CLAIM_LINE_HCC_ID
HAVING
COUNT( * ) > 1;

IF @@rowcount > 0 RAISERROR(  'Non-distinct line counts for final output.  Review and correct the code for WEA.DN.MEDICAL_CLAIMS_VIEWs.', 16, 1 );

/*

SELECT DISTINCT
Base.*
FROM
WEA.DN.MEDICAL_CLAIMS_VIEW AS Base

	JOIN #LineDups AS Dups
		ON Dups.CLAIM_HCC_ID = Base.CLAIM_HCC_ID
		AND Dups.CLAIM_LINE_HCC_ID = Base.CLAIM_LINE_HCC_ID

ORDER BY
 Base.CLAIM_HCC_ID
,Base.CLAIM_LINE_HCC_ID

*/