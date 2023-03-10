USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[Geocoded Data From Quest Analytics Into Geocoded Addresses]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Geocoded Data From Quest Analytics Into Geocoded Addresses] AS

BEGIN

/**********************************************************************************/
/* DECLARE INITIAL PARAMETERS FOR THE TRANSACTION LOG */

DECLARE 
 @TransactionName			VARCHAR(1000) = ( '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME( @@PROCID ) + '].[' + OBJECT_NAME( @@PROCID ) + ']')
,@TransactionDescription	VARCHAR(1000) = 'Add Geocoded Information from Quest Analytics'
,@RowCountCheck				INT;

/**********************************************************************************/
/* PREP THE TEMP TABLE */

IF OBJECT_ID( 'TEMPDB..#Results' ) IS NOT NULL DROP TABLE #Results;

/**********************************************************************************/
/* CREATE THE PROPER TABLE STRUCTURE */

WITH #AllColumns AS (

SELECT
 --[Row ID]
 [Address Line Key] =
	CASE 
		WHEN [Address Line Key] = 'NULL' THEN NULL
		ELSE CAST( [Address Line Key] AS BIGINT )
	END
,[ADDRESS_LINE] =
	CASE 
		WHEN [ADDRESS_LINE] = 'NULL' THEN NULL
		ELSE [ADDRESS_LINE]
	END
--,[Quest Clean Address]
--,[Orig_Address]
--,[ADDRESS_LINE_2]
,[CITY_NAME] =
	CASE 
		WHEN [CITY_NAME] = 'NULL' THEN NULL
		ELSE [CITY_NAME]
	END
,[COUNTRY_CODE] =
	CASE 
		WHEN [COUNTRY_CODE] = 'NULL' THEN NULL
		ELSE [COUNTRY_CODE]
	END
,[COUNTRY_NAME] =
	CASE 
		WHEN [COUNTRY_NAME] = 'NULL' THEN NULL
		ELSE [COUNTRY_NAME]
	END
,[COUNTY_NAME] =
	CASE 
		WHEN [COUNTY_NAME] = 'NULL' THEN NULL
		ELSE [COUNTY_NAME]
	END
,[STATE_CODE] =
	CASE 
		WHEN [STATE_CODE] = 'NULL' THEN NULL
		ELSE [STATE_CODE]
	END
,[ZIP_CODE] =
	CASE 
		WHEN [ZIP_CODE] = 'NULL' THEN NULL
		ELSE [ZIP_CODE]
	END
,[ZIP_4_CODE] =
	CASE 
		WHEN [ZIP_4_CODE] = 'NULL' THEN NULL
		ELSE [ZIP_4_CODE]
	END
--,[Quest Clean Zip] =
--	CASE 
--		WHEN [Quest Clean Zip] = 'NULL' THEN NULL
--		ELSE [Quest Clean Zip]
--	END
--,[Orig_Zip] =
--	CASE 
--		WHEN [Orig_Zip] = 'NULL' THEN NULL
--		ELSE [Orig_Zip]
--	END
--,[Date Updated] =
--	CASE 
--		WHEN [Date Updated] = 'NULL' THEN NULL
--		ELSE [Date Updated]
--	END
,[Latitude] =
	CASE
		WHEN [Latitude] = 'NULL' THEN NULL
		ELSE CAST( [Latitude] AS INT )
	END
,[Longitude] =
	CASE
		WHEN [Longitude] = 'NULL' THEN NULL
		ELSE CAST( [Longitude] AS INT )
	END
,[GeoInfo] =
	CASE 
		WHEN [GeoInfo] = 'NULL' THEN NULL
		ELSE [GeoInfo]
	END
,[Standard Address] =
	CASE 
		WHEN [StandardAddress] = 'NULL' THEN NULL
		ELSE [StandardAddress]
	END
,[Standard City] =
	CASE 
		WHEN [StandardCity] = 'NULL' THEN NULL
		ELSE [StandardCity]
	END
,[Standard State] =
	CASE 
		WHEN [StandardState] = 'NULL' THEN NULL
		ELSE [StandardState]
	END
,[StandardZip] =
	CASE 
		WHEN [StandardZip] = 'NULL' THEN NULL
		ELSE [StandardZip]
	END
,[Standard 3 Digit Zip] =
	LEFT( 
	CASE 
		WHEN [StandardZip] = 'NULL' THEN NULL
		ELSE [StandardZip]
	END
	, 3 )
,[Population Density] =
	NULL
,[US Census] =
	NULL
,[County FIPS] =
	NULL
,[CountySSA] =
	CASE 
		WHEN [CountySSA] = 'NULL' THEN NULL
		ELSE [CountySSA]
	END
,[County Name] =
	NULL
,[County Class] =
	NULL
,[CBSA Code] =
	NULL
,[CBSA Name] =
	NULL
,[True Latitude] =
	NULL
,[True Longitude] =
	NULL
,[True Geographical Point] =
	NULL
,[Source] = 
	NULL
,[Date Added] =
	NULL
  FROM [DEPT_Actuary_JMarx].[dbo].[Geocoded Addresseses by Quest Commas Removed]

),

/**********************************************************************************/
/* CONVERT TO PROPER LATITUDE AND LONGITUDE */

#LatAndLong AS (

SELECT
 [Address Line Key]
,[ADDRESS_LINE]
,[CITY_NAME]
,[COUNTRY_CODE]
,[COUNTRY_NAME]
,[COUNTY_NAME]
,[STATE_CODE]
,[ZIP_CODE]
,[ZIP_4_CODE]
,[Latitude]
,[Longitude]
,[GeoInfo]
,[Standard Address]
,[Standard City]
,[Standard State]
,[StandardZip]
,[Standard 3 Digit Zip]
,[Population Density]
,[US Census]
,[County FIPS]
,[CountySSA]
,[County Name]
,[County Class]
,[CBSA Code]
,[CBSA Name]
,[True Latitude] =
	CAST( [Latitude] AS NUMERIC(38,20) ) * POWER( 10.00000000000, ( -1 * ( LEN( [Latitude] ) - 2 ) ) )
,[True Longitude] =
	-1 * CAST( [Longitude] AS NUMERIC(38,20) ) * POWER( 10.00000000000, ( -1 * ( LEN( [Longitude] ) - 2 ) ) )
,[True Geographical Point]
,[Source]
,[Date Added] =
	CAST( GETDATE() AS DATE )
FROM
#AllColumns

)

/**********************************************************************************/
/* ADD THE GEOGRAPHIC POINT */

SELECT
 [Address Line Key]
,[ADDRESS_LINE]
,[CITY_NAME]
,[COUNTRY_CODE]
,[COUNTRY_NAME]
,[COUNTY_NAME]
,[STATE_CODE]
,[ZIP_CODE]
,[ZIP_4_CODE]
,[Latitude]
,[Longitude]
,[GeoInfo]
,[Standard Address]
,[Standard City]
,[Standard State]
,[StandardZip]
,[Standard 3 Digit Zip]
,[Population Density]
,[US Census]
,[County FIPS]
,[CountySSA]
,[County Name]
,[County Class]
,[CBSA Code]
,[CBSA Name]
,[True Latitude]
,[True Longitude]
,[True Geographical Point] = 
	CASE
		WHEN [True Latitude] IS NOT NULL AND [True Longitude]	 IS NOT NULL THEN GEOGRAPHY::Point( [True Latitude], [True Longitude]	, 4326 )
		ELSE NULL
	END
,[Source] = 
	'Quest Analytics'
,[Date Added]
INTO
#Results
FROM
#LatAndLong

SET
@RowCountCheck = ( SELECT COUNT( * ) FROM #Results );

/**********************************************************************************/
/* INSERT THE FINAL CONVERSIONS INTO THE PRODUCTION TABLE */

INSERT INTO
DEPT_Actuary.dbo.[Geocoded Addresses]
SELECT * FROM #Results;

/**********************************************************************************/
/* INSERT A ROW INTO THE TRANSACTION LOG */

IF ( SELECT COUNT(*) FROM DEPT_Actuary.dbo.[Geocoded Addresses] WHERE [Source] = 'Quest Analytics' AND [Date Added] = CAST( GETDATE() AS DATE ) ) = @RowCountCheck
 BEGIN 
	DROP TABLE [DEPT_Actuary_JMarx].[dbo].[Geocoded Addresseses by Quest Commas Removed]
	EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
		,@TransactionStatus = 'Success'
		,@TransactionComment = 'Inserts were made into DEPT_Actuary.dbo.[Geocoded Addresses] for today from Quest Analytics'
		,@TransactionName =  @TransactionName
 END
ELSE IF ( SELECT COUNT(*) FROM DEPT_Actuary.dbo.[Geocoded Addresses] WHERE [Source] = 'Quest Analytics' AND [Date Added] = CAST( GETDATE() AS DATE ) ) = 0
 BEGIN
	EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Failure'
	,@TransactionComment = 'No inserts were made into DEPT_Actuary.dbo.[Geocoded Addresses] for today from Quest Analytics'
	,@TransactionName =  @TransactionName
 END
ELSE IF ( SELECT COUNT(*) FROM DEPT_Actuary.dbo.[Geocoded Addresses] WHERE [Source] = 'Quest Analytics' AND [Date Added] = CAST( GETDATE() AS DATE ) ) < @RowCountCheck
 BEGIN
	EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Partial Failure'
	,@TransactionComment = 'Not all inserts were made into DEPT_Actuary.dbo.[Geocoded Addresses] for today from Quest Analytics'
	,@TransactionName =  @TransactionName
 END
ELSE IF ( SELECT COUNT(*) FROM DEPT_Actuary.dbo.[Geocoded Addresses] WHERE [Source] = 'Quest Analytics' AND [Date Added] = CAST( GETDATE() AS DATE ) ) > @RowCountCheck
 BEGIN
	EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Potential Duplicates'
	,@TransactionComment = 'More rows are in the table DEPT_Actuary.dbo.[Geocoded Addresses] than were created from the stored procedure for today from Quest Analytics'
	,@TransactionName =  @TransactionName
 END
 ELSE
 BEGIN
	EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Failure'
	,@TransactionComment = 'No inserts were made into DEPT_Actuary.dbo.[Geocoded Addresses] for today from Quest Analytics'
	,@TransactionName =  @TransactionName
 END

END
GO
