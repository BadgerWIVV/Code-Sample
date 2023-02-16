/**************************************************************************************************************/
/* Declare parameters */

DECLARE
 @StartDate						DATE	=	'2019-01-01'
,@EndDate						DATE	=	'2019-12-31'
,@ConsecutiveConcurrentUseLimit	INT	=	30
;

/**************************************************************************************************************/
/* Use to create a date table, but feel free to source from an existing one if able */

IF OBJECT_ID( 'TEMPDB.DBO.#DateSeed' ) IS NOT NULL
	BEGIN
		DROP TABLE #DateSeed
	END;

WITH x AS (
SELECT 
 [start_date]
,[end_date] =
	@EndDate
FROM (
	SELECT TOP 1 
	[start_date] = @StartDate
 ) tmp

 UNION ALL
 
 SELECT 
  DATEADD(DAY,1,[start_date])
 ,[end_date]
 FROM x
 WHERE
 DATEADD(DAY,1,[start_date]) <= [end_date]
 )
 
SELECT 
 [Date] =
	[Start_Date]
INTO
#DateSeed
FROM x
OPTION (MAXRECURSION 366 )   /* This must be changed to at least the number of dates you wish to include */

/* FOR DEBUGGING */ --SELECT * FROM #DateSeed ORDER BY [Start_Date]

/**************************************************************************************************************/
/* Find all the benzo scripts available */

IF OBJECT_ID( 'TEMPDB.DBO.#BenzoScripts' ) IS NOT NULL
	BEGIN
		DROP TABLE #BenzoScripts
	END;

SELECT 
 a.[Whio_MemberId]
,a.[PharmClaim_xKey]
,a.[PrescriptionDate]
,a.[DaysSupply]
,[BenzoEndDate] =
	DATEADD(DAY, DaysSupply-1, PrescriptionDate) 
INTO
#BenzoScripts
FROM 
WHIO_SID.[dbo].[xFact_IntPharmClaim] a

	LEFT JOIN WHIO_SID.[dbo].[xDim_MedFile] b
		ON a.NationalDrugCode = b.NationalDrugCode

WHERE
DrugClass IN ('*Benzodiazepines**','*Anticonvulsants - Benzodiazepines**')
AND
PrescriptionDate >= @StartDate
AND
PrescriptionDate <= @EndDate
AND
whio_MemberID IS NOT NULL
AND
DaysSupply > 0

/* FOR DEBUGGING */ --SELECT * FROM #BenzoScripts
/* FOR DEBUGGING */ --SELECT * FROM #BenzoScripts WHERE Whio_MemberId = 'WHIO1000030' 

/**************************************************************************************************************/
/* Find all the dates each member had a benzo available */

IF OBJECT_ID( 'TEMPDB.DBO.#BenzoMemberDates' ) IS NOT NULL
	BEGIN
		DROP TABLE #BenzoMemberDates
	END;

SELECT
 #BenzoScripts.Whio_MemberId
,#DateSeed.[Date]
INTO
#BenzoMemberDates
FROM
#DateSeed
	
	LEFT JOIN #BenzoScripts
		ON	#DateSeed.[Date] >= #BenzoScripts.PrescriptionDate
		AND #DateSeed.[Date] <= #BenzoScripts.[BenzoEndDate]

GROUP BY
 #BenzoScripts.Whio_MemberId
,#DateSeed.[Date]

/* FOR DEBUGGING */ --SELECT TOP 100 * FROM #BenzoMemberDates ORDER BY Whio_MemberId, [Date]
/* FOR DEBUGGING */ --SELECT * FROM #BenzoMemberDates WHERE Whio_MemberId = 'WHIO1000030' ORDER BY [Date]

/**************************************************************************************************************/
/* Find all opioid scripts for members */

IF OBJECT_ID( 'TEMPDB.DBO.#OpioidScripts' ) IS NOT NULL
	BEGIN
		DROP TABLE #OpioidScripts
	END;

SELECT 
 a.[Whio_MemberId]
,a.[PharmClaim_xKey]
,a.[PrescriptionDate]
,a.[DaysSupply]
,[BenzoEndDate] =
	DATEADD(DAY, DaysSupply-1, PrescriptionDate) 
INTO
#OpioidScripts
FROM 
WHIO_SID.[dbo].[xFact_IntPharmClaim] a

	LEFT JOIN WHIO_SID.[dbo].[xDim_MedFile] b
		ON a.NationalDrugCode = b.NationalDrugCode

WHERE
DrugSubClass IN ( '*Opioid Agonists***',
'*Codeine Combinations***', '*Hydrocodone Combinations***', '*Opioid Combinations***',
'*Tramadol Combinations***', '*Opioid Partial Agonists***', '*Antitussive - Opioid***', '*Opioid Antitussive-Antihistamine***',
'*Opioid Antitussive-Decongestant-Antihistamine***' )
AND
PrescriptionDate >= @StartDate
AND
PrescriptionDate <= @EndDate
AND
whio_MemberID IS NOT NULL
AND
DaysSupply > 0

/* FOR DEBUGGING */ --SELECT * FROM #OpioidScripts ORDER BY [Whio_MemberId], [PharmClaim_xKey]
/* FOR DEBUGGING */ --SELECT * FROM OpioidScripts WHERE Whio_MemberId = 'WHIO1000030' 

/**************************************************************************************************************/
/* Find all the dates each member had an opioid available */

IF OBJECT_ID( 'TEMPDB.DBO.#OpioidMemberDates' ) IS NOT NULL
	BEGIN
		DROP TABLE #OpioidMemberDates
	END;

SELECT
 #OpioidScripts.Whio_MemberId
,#DateSeed.[Date]
INTO
#OpioidMemberDates
FROM
#DateSeed
	
	LEFT JOIN #OpioidScripts
		ON	#DateSeed.[Date] >= #OpioidScripts.PrescriptionDate
		AND #DateSeed.[Date] <= #OpioidScripts.[BenzoEndDate]

GROUP BY
 #OpioidScripts.Whio_MemberId
,#DateSeed.[Date]

/* FOR DEBUGGING */ --SELECT TOP 100 * FROM #OpioidMemberDates ORDER BY Whio_MemberId, [Date]
/* FOR DEBUGGING */ --SELECT * FROM #OpioidMemberDates WHERE Whio_MemberId = 'WHIO1000030' ORDER BY [Date]

/**************************************************************************************************************/
/* Make a Cartesian join for all members and dates */

IF OBJECT_ID( 'TEMPDB.DBO.#MemberDates' ) IS NOT NULL
	BEGIN
		DROP TABLE #MemberDates
	END;

WITH Members AS (
SELECT
DISTINCT
Whio_MemberId
FROM
#OpioidMemberDates

UNION

SELECT
Whio_MemberId
FROM
#BenzoMemberDates

)

SELECT
 Whio_MemberId
,#DateSeed.[Date]
INTO
#MemberDates
FROM
Members

CROSS JOIN #DateSeed

/**************************************************************************************************************/
/* All Member Dates With Drug use Indicators */

IF OBJECT_ID( 'TEMPDB.DBO.#MemberDrugAvailabilities' ) IS NOT NULL
	BEGIN
		DROP TABLE #MemberDrugAvailabilities
	END;

SELECT
 #MemberDates.Whio_MemberId
,#MemberDates.[Date]
,[Benzo Available] =
	CASE
		WHEN #BenzoMemberDates.Whio_MemberId IS NOT NULL THEN 1
		ELSE 0
	END
,[Opioid Available] =
	CASE
		WHEN #OpioidMemberDates.Whio_MemberId IS NOT NULL THEN 1
		ELSE 0
	END
,[Opioid and Benzo Available] =
	CASE
		WHEN #OpioidMemberDates.Whio_MemberId IS NOT NULL AND #BenzoMemberDates.Whio_MemberId IS NOT NULL THEN 1
		ELSE 0
	END
INTO
#MemberDrugAvailabilities
FROM
#MemberDates

	LEFT JOIN #BenzoMemberDates
		ON	#BenzoMemberDates.[Date] = #MemberDates.[Date]
		AND #BenzoMemberDates.Whio_MemberId = #MemberDates.Whio_MemberId

	LEFT JOIN #OpioidMemberDates
		ON	#OpioidMemberDates.[Date] = #MemberDates.[Date]
		AND #OpioidMemberDates.Whio_MemberId = #MemberDates.Whio_MemberId

/* FOR DEBUGGING */ --SELECT TOP 100 * FROM #MemberDrugAvailabilities ORDER BY Whio_MemberId, [Date]
/* FOR DEBUGGING */ --SELECT * FROM #MemberDrugAvailabilities WHERE Whio_MemberId = 'WHIO1000430' ORDER BY Whio_MemberId, [Date]

/**************************************************************************************************************/
/* Find the length of consecutive concurrent use */

IF OBJECT_ID( 'TEMPDB.DBO.#ConsecutiveConcurrentUseLength' ) IS NOT NULL
	BEGIN
		DROP TABLE #ConsecutiveConcurrentUseLength
	END;

WITH Gaps AS (

SELECT
 *
,[Prior Opioid and Benzo Available Status] =
	LAG([Opioid and Benzo Available]) OVER( PARTITION BY Whio_MemberId ORDER BY [Date] ASC )
,[Next Opioid and Benzo Available Status] =
	LEAD([Opioid and Benzo Available]) OVER( PARTITION BY Whio_MemberId ORDER BY [Date] ASC )
FROM
#MemberDrugAvailabilities

),

StartAndEnd AS (

SELECT
*
,[Start Date] =
	CASE
		WHEN ISNULL( [Prior Opioid and Benzo Available Status], 0 ) = 0 AND [Opioid and Benzo Available] = 1 THEN [Date]
		ELSE NULL
	END
,[End Date] =
	CASE
		WHEN ISNULL( [Next Opioid and Benzo Available Status], 0 ) = 0 AND [Opioid and Benzo Available] = 1 THEN [Date]
		ELSE NULL
	END
FROM
Gaps

),

MatchingEndDates AS (

SELECT
*
,[Matching End Date] =
	LEAD([End Date]) OVER( PARTITION BY Whio_MemberId ORDER BY [Date] ASC )
FROM
StartAndEnd
WHERE
[Start Date] IS NOT NULL
OR
[End Date] IS NOT NULL

)

SELECT
 [Whio_memberID]
,[Start Date]
,[End Date] =
	[Matching End Date]
,[Consecutive Concurrent Use] =
	DATEDIFF( DAY, [Start Date], [Matching End Date] ) + 1
INTO
#ConsecutiveConcurrentUseLength
FROM
MatchingEndDates
WHERE
[Start Date] IS NOT NULL

/* FOR DEBUGGING */ --SELECT TOP 100 * FROM #ConsecutiveConcurrentUseLength

/**************************************************************************************************************/
/* Attach consecutive use to drug availability  */

IF OBJECT_ID( 'TEMPDB.DBO.#MemberDrugAvailabilitiesWithConsecutiveConcurrentUse' ) IS NOT NULL
	BEGIN
		DROP TABLE #MemberDrugAvailabilitiesWithConsecutiveConcurrentUse
	END;

SELECT
 #MemberDrugAvailabilities.*
,#ConsecutiveConcurrentUseLength.[Start Date]
,#ConsecutiveConcurrentUseLength.[End Date]
,#ConsecutiveConcurrentUseLength.[Consecutive Concurrent Use]
INTO
#MemberDrugAvailabilitiesWithConsecutiveConcurrentUse
FROM
#MemberDrugAvailabilities

	LEFT JOIN #ConsecutiveConcurrentUseLength
		ON	#ConsecutiveConcurrentUseLength.Whio_MemberId = #MemberDrugAvailabilities.Whio_MemberId
		AND #MemberDrugAvailabilities.[Date] >= #ConsecutiveConcurrentUseLength.[Start Date]
		AND #MemberDrugAvailabilities.[Date] <= #ConsecutiveConcurrentUseLength.[End Date]

/* FOR DEBUGGING */ --SELECT TOP 100 * FROM #MemberDrugAvailabilitiesWithConsecutiveConcurrentUse

/**************************************************************************************************************/
/* Member Dates Over Concurrent Use Limit */

IF OBJECT_ID( 'TEMPDB.DBO.#MemberDatesOverConcurrentUseLimit' ) IS NOT NULL
	BEGIN
		DROP TABLE #MemberDatesOverConcurrentUseLimit
	END;

SELECT
*
INTO
#MemberDatesOverConcurrentUseLimit
FROM
#MemberDrugAvailabilitiesWithConsecutiveConcurrentUse
WHERE
[Consecutive Concurrent Use] >= @ConsecutiveConcurrentUseLimit

/* FOR DEBUGGING */ --SELECT TOP 100 * FROM #MemberDatesOverConcurrentUseLimit

/**************************************************************************************************************/
/* Members Over Concurrent Use Limit */

IF OBJECT_ID( 'TEMPDB.DBO.#MembersOverConcurrentUseLimit' ) IS NOT NULL
	BEGIN
		DROP TABLE #MembersOverConcurrentUseLimit
	END;

SELECT
Whio_MemberId
INTO
#MembersOverConcurrentUseLimit
FROM
#MemberDatesOverConcurrentUseLimit
GROUP BY
Whio_MemberId

/* FOR DEBUGGING */ --SELECT TOP 100 * FROM #MembersOverConcurrentUseLimit

/**************************************************************************************************************/
/* Results  */

SELECT TOP 0 [Members With Concurrent Drug Availablity Exceeding Day Limit] = NULL

SELECT  * FROM #MembersOverConcurrentUseLimit






SELECT TOP 0 [Member Date Availablility With Concurrent Drug Availablity Exceeding Day Limit] = NULL

SELECT
#MemberDrugAvailabilitiesWithConsecutiveConcurrentUse.*
FROM
#MemberDrugAvailabilitiesWithConsecutiveConcurrentUse

	JOIN #MembersOverConcurrentUseLimit
		ON	#MembersOverConcurrentUseLimit.Whio_MemberId = #MemberDrugAvailabilitiesWithConsecutiveConcurrentUse.Whio_MemberId

ORDER BY
 #MemberDrugAvailabilitiesWithConsecutiveConcurrentUse.Whio_MemberId
,#MemberDrugAvailabilitiesWithConsecutiveConcurrentUse.[Date]
