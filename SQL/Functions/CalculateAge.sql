USE [WEA]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_CalculateAge]    Script Date: 6/2/2022 4:35:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[fn_CalculateAge](

 @Start_Date	AS DATETIME
,@End_Date		AS DATETIME

)

RETURNS TINYINT

AS

BEGIN

			/* Logic used by Lori Otteson from URText.  Appears accurate to the year but may not be for smaller granularity */
    RETURN FLOOR( ( CAST( CONVERT( VARCHAR(8), @End_Date, 112 ) AS INT ) - CAST( CONVERT( VARCHAR(8), @Start_Date, 112 ) AS INT ) ) / 10000 )
	
END
GO


