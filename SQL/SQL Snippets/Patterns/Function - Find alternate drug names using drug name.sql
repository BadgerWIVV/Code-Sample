USE [HCI]
GO

/****** Object:  UserDefinedFunction [SUPPORT].[fn_FIND_ALTERNATE_DRUG_NAMES]    Script Date: 1/19/2021 7:39:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [SUPPORT].[fn_FIND_ALTERNATE_DRUG_NAMES](
 @NAME		VARCHAR(255)	= NULL
)
RETURNS @Output TABLE(
 [Names]		VARCHAR(MAX)
 )

AS BEGIN

DECLARE @Temp TABLE (
 [Names]	VARCHAR(MAX)
)

INSERT INTO @Temp
SELECT
[Names] =
	[Generic Name]
FROM
HCI.SUPPORT.[fn_FIND_GENERIC_NAMES] ( @NAME );


INSERT INTO @Temp
SELECT
[Names] = 
	[Brand Name]
FROM
HCI.SUPPORT.[fn_FIND_BRAND_NAMES] ( @NAME );


INSERT INTO @Output
SELECT
[Names]
FROM
@Temp
GROUP BY
[Names]


RETURN

/**************************************************************************************************************/
/* EXAMPLE CALLING OF FUNCTION */

/*

SELECT
*
FROM
HCI.SUPPORT.[fn_FIND_ALTERNATE_DRUG_NAMES] ( 'Capecitabine' );

*/

END;
GO


