USE [HCI]
GO

/****** Object:  UserDefinedFunction [SUPPORT].[fn_FIND_CPTs]    Script Date: 1/19/2021 7:43:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [SUPPORT].[fn_FIND_CPTs](
 @NAME		VARCHAR(255)	= NULL
)
RETURNS @Output TABLE(
 [CPT]		VARCHAR(MAX)
 )

AS BEGIN

DECLARE @DistinctNames TABLE (
 [Name]	VARCHAR(MAX)
);

DECLARE @BrandNames TABLE (
 [Brand Name]	VARCHAR(MAX)
);

DECLARE @GenericNames TABLE (
 [Generic Name]	VARCHAR(MAX)
);

INSERT INTO @DistinctNames
SELECT
[Name] =
	[Names]
FROM
HCI.[SUPPORT].[fn_FIND_ALTERNATE_DRUG_NAMES] ( @NAME );

INSERT INTO @GenericNames
SELECT
GenericName.[Generic Name]
FROM
@DistinctNames AS Names

	CROSS APPLY HCI.SUPPORT.fn_FIND_GENERIC_NAMES ( Names.[Name] ) AS GenericName

WHERE
GenericName.[Generic Name] IS NOT NULL
GROUP BY
GenericName.[Generic Name];


INSERT INTO @BrandNames
SELECT
BrandName.[Brand Name]
FROM
@DistinctNames AS Names

	CROSS APPLY HCI.SUPPORT.fn_FIND_BRAND_NAMES ( Names.[Name] ) AS BrandName

WHERE
BrandName.[Brand Name] IS NOT NULL
GROUP BY
BrandName.[Brand Name];


INSERT INTO @Output
SELECT
[CPT] =
	[STANDARDIZED_SERVICE_CODE]
FROM
[WEA_EDW].[DIM].[SERVICE_DIM]
WHERE
(
[SERVICE_SHORT_DESCRIPTION] IN ( SELECT [Brand Name] FROM @BrandNames )
OR
[SERVICE_LONG_DESCRIPTION] IN ( SELECT [Generic Name] FROM @GenericNames )
)
AND
SERVICE_TYPE_NAME IN ( 'CPT-4 code', 'HCPCS code' )
GROUP BY
[STANDARDIZED_SERVICE_CODE];

RETURN

/**************************************************************************************************************/
/* EXAMPLE CALLING OF FUNCTION */

/*

SELECT
[CPT]
FROM
HCI.SUPPORT.[fn_FIND_CPTs] ( 'Capecitabine' );

*/

END;
GO


