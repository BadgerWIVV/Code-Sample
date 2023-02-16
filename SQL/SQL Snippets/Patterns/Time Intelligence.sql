/* Time Intelligence to start beginning of the year 3 years ago, until the last day of the previous month */

DECLARE
 @CurrentDate		DATE	=	GETDATE()
,@EndOfMonth		DATE
,@StartOfNextMonth	DATE
,@StartOfThisMonth	DATE
--,@EndOfLastMonth	DATE
,@CurrentYear		INT
,@YearsLookBack		INT	= 3
,@YearsOfLookback	INT
,@StartingDate		DATE
,@EndOfYear			DATE;

SET @EndOfMonth			= ( SELECT EOMONTH( @CurrentDate ) );
SET @StartOfNextMonth	= ( SELECT DATEADD( DAY, 1, @EndOfMonth ) );
SET @StartOfThisMonth	= ( SELECT DATEADD( MONTH, -1, @StartOfNextMonth ) );
--SET @EndOfLastMonth		= ( SELECT DATEADD( DAY, -1, @StartOfThisMonth ) );
SET @CurrentYear		= ( SELECT YEAR ( @CurrentDate ) );
SET @YearsOfLookback		= ( SELECT @CurrentYear - @YearsLookBack );
SET @StartingDate		= ( SELECT DATEFROMPARTS( @YearsOfLookback, '01', '01' ) );
SET @EndOfYear			= ( SELECT DATEFROMPARTS( @CurrentYear, '12', '31' ) );
--SELECT
-- @CurrentDate		
--,@EndOfMonth		
--,@StartOfNextMonth	
--,@StartOfThisMonth	
----,@EndOfLastMonth	
--,@CurrentYear		
--,@YearsLookBack
--,@YearsOfLookback		
--,@StartingDate		


SELECT
 [Date] =
	CONVERT( DATE,[DATE_VALUE],112 )
,[Work Day] =
	CHOOSE( DATEPART( dw,[DATE_VALUE] ), 'WEEKEND','Weekday','Weekday','Weekday','Weekday','Weekday','WEEKEND' )
,[Day of Week Order] =
	[DAY_OF_WEEK]
,[Day of Month] =
	[DAY_OF_MONTH]
,[Day of Week] =
	DATENAME( weekday,[DATE_VALUE] )
,[Year] =
	YEAR_NUMBER
,[Half Year] =
	[HALF_NAME_WITH_YEAR]
,[Half Year Number] =
	[HALF_NUMBER]
,[Month Order] =
	[MONTH_COUNT]
,[Month] =
	[MONTH_NAME]
,[Month Year] =
	[MONTH_NAME_WITH_YEAR]
,[Month Number] =
	[MONTH_NUMBER]
,[Quarter Order] =
	[QUARTER_COUNT]
,[Quarter] =
	[QUARTER_NAME]
,[Quarter Year] =
	[QUARTER_NAME_WITH_YEAR]
,[Quarter Number] =
	[QUARTER_NUMBER]
FROM
[wea_prod_dw].[dbo].[DATE_DIMENSION]
WHERE
DATE_VALUE >= @StartingDate 
AND
DATE_VALUE < @EndOfYear