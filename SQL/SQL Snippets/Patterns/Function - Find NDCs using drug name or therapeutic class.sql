USE [HCI]
GO

CREATE FUNCTION [SUPPORT].[fn_FIND_NDCS_BY_NAME_OR_CLASS](
 @Drug1OrClass0							BIT
,@TherapeuticClassLevel					INT
,@TherapeuticClassName					VARCHAR(100)
,@DrugName								VARCHAR(100)
)
RETURNS @Output TABLE(
 [NDC]						VARCHAR(MAX)
,[Brand Name]				VARCHAR(MAX)
,[Generic Name]				VARCHAR(MAX)
,[EDW Therapeutic Class 1]	VARCHAR(MAX)
,[EDW Therapeutic Class 2]	VARCHAR(MAX)
,[EDW Therapeutic Class 3]	VARCHAR(MAX)
,[Source]					VARCHAR(MAX)
 )

AS BEGIN

INSERT INTO @Output
SELECT
 NavitusNDC.[NDC_CODE]
,[Brand Name] =
	NavitusNDC.[LABEL_NAME]
,[Generic Name] =
	NavitusNDC.[Generic_Name]
,[EDW Therapeutic Class 1] =
	TherapeuticClass.[THERAPEUTIC_CLASS_2_DESCRIPTION]
,[EDW Therapeutic Class 2] =
	TherapeuticClass.[THERAPEUTIC_CLASS_4_DESCRIPTION]
,[EDW Therapeutic Class 3] =
	TherapeuticClass.[THERAPEUTIC_CLASS_6_DESCRIPTION]
,[Source] =
	'Navitus - Therapeutic Class'
FROM
[WEA_EDW].[DIM].[NVT_NDC_CODE_DIM] AS NavitusNDC

	JOIN WEA_EDW.[DIM].[THERAPEUTIC_CLASS_REFERENCE_DIM] AS TherapeuticClass
		ON TherapeuticClass.[THERAPEUTIC_CLASS_REFERENCE_DIM_KEY] = NavitusNDC.[THERAPEUTIC_CLASS_REFERENCE_DIM_KEY]

WHERE
@Drug1OrClass0 = 0
AND
CASE
	WHEN @TherapeuticClassLevel = 1 AND TherapeuticClass.[THERAPEUTIC_CLASS_2_DESCRIPTION] = @TherapeuticClassName THEN 1
	WHEN @TherapeuticClassLevel = 2 AND TherapeuticClass.[THERAPEUTIC_CLASS_4_DESCRIPTION] = @TherapeuticClassName THEN 1
	WHEN @TherapeuticClassLevel = 3 AND TherapeuticClass.[THERAPEUTIC_CLASS_6_DESCRIPTION] = @TherapeuticClassName THEN 1
	ELSE 0
END = 1


UNION ALL

SELECT
 MedImpactNDC.[PRODUCT_SERVICE_ID]
,[Brand Name] =
	MedImpactNDC.[DRUG_LABEL_NAME]
,[Generic Name] =
	MedImpactNDC.[Generic_Name]
,[EDW Therapeutic Class 1] =
	TherapeuticClass.[THERAPEUTIC_CLASS_2_DESCRIPTION]
,[EDW Therapeutic Class 2] =
	TherapeuticClass.[THERAPEUTIC_CLASS_4_DESCRIPTION]
,[EDW Therapeutic Class 3] =
	TherapeuticClass.[THERAPEUTIC_CLASS_6_DESCRIPTION]
,[Source] =
	'MedImpact - Therapeutic Class'
FROM
[WEA_EDW].[DIM].[NDC_CODE_MI_DIM] AS MedImpactNDC

	JOIN WEA_EDW.[DIM].[THERAPEUTIC_CLASS_REFERENCE_DIM] AS TherapeuticClass
		ON TherapeuticClass.[THERAPEUTIC_CLASS_REFERENCE_DIM_KEY] = MedImpactNDC.[THERAPEUTIC_CLASS_REFERENCE_DIM_KEY]

WHERE
@Drug1OrClass0 = 0
AND
CASE
	WHEN @TherapeuticClassLevel = 1 AND TherapeuticClass.[THERAPEUTIC_CLASS_2_DESCRIPTION] = @TherapeuticClassName THEN 1
	WHEN @TherapeuticClassLevel = 2 AND TherapeuticClass.[THERAPEUTIC_CLASS_4_DESCRIPTION] = @TherapeuticClassName THEN 1
	WHEN @TherapeuticClassLevel = 3 AND TherapeuticClass.[THERAPEUTIC_CLASS_6_DESCRIPTION] = @TherapeuticClassName THEN 1
	ELSE 0
END = 1

UNION ALL

SELECT
 MedImpactNDC.[PRODUCT_SERVICE_ID]
,[Brand Name] =
	MedImpactNDC.[DRUG_LABEL_NAME]
,[Generic Name] =
	MedImpactNDC.[Generic_Name]
,[EDW Therapeutic Class 1] =
	TherapeuticClass.[THERAPEUTIC_CLASS_2_DESCRIPTION]
,[EDW Therapeutic Class 2] =
	TherapeuticClass.[THERAPEUTIC_CLASS_4_DESCRIPTION]
,[EDW Therapeutic Class 3] =
	TherapeuticClass.[THERAPEUTIC_CLASS_6_DESCRIPTION]
,[Source] =
	'MedImpact - Drug Name'
FROM
[WEA_EDW].[DIM].[NDC_CODE_MI_DIM] AS MedImpactNDC

	LEFT JOIN WEA_EDW.[DIM].[THERAPEUTIC_CLASS_REFERENCE_DIM] AS TherapeuticClass
		ON TherapeuticClass.[THERAPEUTIC_CLASS_REFERENCE_DIM_KEY] = MedImpactNDC.[THERAPEUTIC_CLASS_REFERENCE_DIM_KEY]

WHERE
@Drug1OrClass0 = 1
AND
CASE
	WHEN MedImpactNDC.[DRUG_LABEL_NAME] LIKE '%' + @DrugName + '%' OR MedImpactNDC.[Generic_Name] LIKE '%' +  @DrugName + '%' THEN 1
	ELSE 0
END = 1


UNION ALL

SELECT
 NavitusNDC.[NDC_CODE]
,[Brand Name] =
	NavitusNDC.[LABEL_NAME]
,[Generic Name] =
	NavitusNDC.[Generic_Name]
,[EDW Therapeutic Class 1] =
	TherapeuticClass.[THERAPEUTIC_CLASS_2_DESCRIPTION]
,[EDW Therapeutic Class 2] =
	TherapeuticClass.[THERAPEUTIC_CLASS_4_DESCRIPTION]
,[EDW Therapeutic Class 3] =
	TherapeuticClass.[THERAPEUTIC_CLASS_6_DESCRIPTION]
,[Source] =
	'Navitus - Drug Name'
FROM
[WEA_EDW].[DIM].[NVT_NDC_CODE_DIM] AS NavitusNDC

	LEFT JOIN WEA_EDW.[DIM].[THERAPEUTIC_CLASS_REFERENCE_DIM] AS TherapeuticClass
		ON TherapeuticClass.[THERAPEUTIC_CLASS_REFERENCE_DIM_KEY] = NavitusNDC.[THERAPEUTIC_CLASS_REFERENCE_DIM_KEY]

WHERE
@Drug1OrClass0 = 1
AND
CASE
	WHEN NavitusNDC.[LABEL_NAME] LIKE '%' + @DrugName + '%' OR NavitusNDC.[Generic_Name] LIKE '%' +  @DrugName + '%' THEN 1
	ELSE 0
END = 1

RETURN

/**************************************************************************************************************/
/* EXAMPLE CALLING OF FUNCTION */

/* Single */
/*

SELECT * FROM HCI.SUPPORT.[fn_FIND_NDCS_BY_NAME_OR_CLASS] ( '1', NULL, NULL, 'Capecitabine' );

*/

/* Multiple */
/*

IF OBJECT_ID( 'TEMPDB.DBO.#BaseDrugs' ) IS NOT NULL
	BEGIN
		DROP TABLE #BaseDrugs
	END;

CREATE TABLE #BaseDrugs (
 [Drug - 1 or Therapeutic Class - 0]	BIT				NOT NULL
,[Therapeutic Class Level]				INT				DEFAULT NULL
,[Therapeutic Class Name]				VARCHAR(100)	DEFAULT NULL
,[Drug Name]							VARCHAR(100)	DEFAULT NULL
);

/**************************************************************************************************************/

INSERT INTO #BaseDrugs VALUES

/* Therapeutic NDCs */

 ( 0, 3, 'Thiazide Diuretics', NULL )
,( 0, 3, 'Thiazide-like Diuretics', NULL )


/* Drug Name NDCs */
 
,( 1, NULL, NULL, 'Clarithromycin' )
,( 1, NULL, NULL, 'Erythromycin' )
,( 1, NULL, NULL, 'Metronidazole' )
,( 1, NULL, NULL, 'Sulfamethoxazole%Trimethoprim' )

/* FOR DEBUGGING */ --SELECT TOP 100 * FROM #BaseDrugs



SELECT
NDCs.*
FROM
#BaseDrugs AS Drugs
	
	CROSS APPLY HCI.SUPPORT.[fn_FIND_NDCS_BY_NAME_OR_CLASS]( Drugs.[Drug - 1 or Therapeutic Class - 0], Drugs.[Therapeutic Class Level], Drugs.[Therapeutic Class Name], Drugs.[Drug Name] ) AS NDCs;

*/

END;
GO