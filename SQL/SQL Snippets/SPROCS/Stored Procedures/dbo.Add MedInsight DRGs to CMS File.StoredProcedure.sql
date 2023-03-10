USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[Add MedInsight DRGs to CMS File]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Add MedInsight DRGs to CMS File] AS

BEGIN

ALTER TABLE [DEPT_Actuary_JMarx].[dbo].[DRG Weights_2015_CN--2015-08-05--JM]
ADD [MedInsight DRG] varchar(3);

UPDATE [DEPT_Actuary_JMarx].[dbo].[DRG Weights_2015_CN--2015-08-05--JM]
SET
[MedInsight DRG] =
CASE WHEN LEN( [MS-DRG] ) = 1 THEN CONCAT( '00',[MS-DRG] )
	  WHEN LEN( [MS-DRG] ) = 2 THEN CONCAT( '0',[MS-DRG] )
	  WHEN LEN( [MS-DRG] ) = 3 THEN [MS-DRG]
	  ELSE NULL
	  END

END
GO
