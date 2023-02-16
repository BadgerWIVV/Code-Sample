USE [HCI]
GO

/****** Object:  UserDefinedFunction [SUPPORT].[fn_FIND_NDCs]    Script Date: 1/19/2021 7:35:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [SUPPORT].[fn_FIND_NDCs](
 @NAME		VARCHAR(255)	= NULL
)
RETURNS @Output TABLE(
 [NDC]		VARCHAR(MAX)
 )

AS BEGIN

DECLARE @DistinctNames TABLE (
 [Name]	VARCHAR(MAX)
);

DECLARE @Temp TABLE (
 [NDC]	VARCHAR(MAX)
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

INSERT INTO @Temp
SELECT
 [NDC] =
	NDC.[PRODUCT_SERVICE_ID]
FROM
[WEA_EDW].[DIM].[NDC_CODE_MI_DIM] AS NDC
WHERE
PRODUCT_SERVICE_NAME IN ( SELECT [Brand Name] FROM @BrandNames )
OR
GENERIC_NAME IN ( SELECT [Generic Name] FROM @GenericNames );



INSERT INTO @Temp
SELECT
[NDC] =
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
SERVICE_TYPE_NAME = 'NDC 5-4-2';


INSERT INTO @Output
SELECT
[NDC]
FROM
@Temp
GROUP BY
[NDC]


RETURN

/**************************************************************************************************************/
/* EXAMPLE CALLING OF FUNCTION */

/*

SELECT
*
FROM
HCI.SUPPORT.[fn_FIND_NDCs] ( 'Capecitabine' );

*/

END;
GO


