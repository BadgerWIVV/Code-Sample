/******************************************************************************************************************************/
/*DECLARE PARAMETERS FOR SCRIPT*/

DECLARE
 @StatusDateRestrictionOnUtils		BIT  = 1			/*INDICATOR TO KNOW IF THE UTILIZATION FROM THE LAST PERIOD SHOULD RESTRICT BASED ON THE SAME CURRENT DATES*/
,@StatusDate						DATE = '2018-01-01'	/*DATE THE STATUS RESTRICTION SHOULD BE LIMITED BY*/

/**************************************************************************************************************/
/* SELECT STATEMENT */
SELECT
1
FROM
DatabaseName.dbo.TEST AS MED

/* PROPER WHERE CLAUSE FOR USING THE FILTER FLAG */
WHERE

/* Option 1, might be slower due to OR, but certainly looks more confusing*/
--(
--( @StatusDateRestrictionOnUtils = 1 AND MED.[ Date] <= @StatusDate )
--OR
--( ISNULL(@StatusDateRestrictionOnUtils, 0 ) = '0' )
--)

/* Option 2, preferred for legibility */
CASE
	WHEN ISNULL(@StatusDateRestrictionOnUtils, 0 ) = '0' THEN 1
	WHEN @StatusDateRestrictionOnUtils = 1 AND MED.[ Date] <= @StatusDate THEN 1
	ELSE 0
END = 1
