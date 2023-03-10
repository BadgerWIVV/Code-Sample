USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[MedInsightProcedureCodeReference]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
USE DEPT_Actuary_JMarx;
GO

/**************************************************************************************************************/
/* QA CHECK */

IF OBJECT_ID( 'DEPT_Actuary_JMarx.dbo.MedInsightProcedureCodeReference' ) IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.MedInsightProcedureCodeReference
	END;


*/

CREATE PROCEDURE [dbo].[MedInsightProcedureCodeReference]  AS 
BEGIN



/**************************************************************************************************************/
/* TRANSATION INITIALIZATION */

BEGIN TRY

BEGIN TRANSACTION


/**************************************************************************************************************/
/* DECLARE PARAMETERS */

DECLARE 
 @QA_Unique_CPT			INT;

/**************************************************************************************************************/
/* QA CHECK */

IF OBJECT_ID( 'TEMPDB.DBO.#QA_CPT_GRAIN' ) IS NOT NULL
	BEGIN
		DROP TABLE #QA_CPT_GRAIN
	END;

SELECT
 PROC_CODE
,[Row Count] =
	COUNT(*)
INTO
#QA_CPT_GRAIN
FROM
MedInsight.ASRPT.RPT_PROC_CODE	
GROUP BY
PROC_CODE
HAVING
COUNT(*) > 1

/**************************************************************************************************************/
/* SET QA PARAMETER */

SET @QA_Unique_CPT = @@ROWCOUNT;

/* FOR DEBUGGING */ --SELECT @QA_Unique_CPT

/**************************************************************************************************************/
/* ERROR HANDLING */

IF @QA_Unique_CPT > 0
	BEGIN
		--THROW 51000, 'The record does not exist.', 1;  
	    RAISERROR ('Error raised in TRY block. Grain of Procedure Codes not maintained.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
	END

IF @QA_Unique_CPT <> 0 AND NOT @QA_Unique_CPT > 0
	BEGIN
		--THROW 51000, 'The record does not exist.', 1;  
	    RAISERROR ('Error raised in TRY block. Unknown error.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
	END

/**************************************************************************************************************/
/* SAVE TABLE FROM MEDINSIGHT */

IF @QA_Unique_CPT = 0
	BEGIN

--	IF OBJECT_ID( 'HCI.SUPPORT.RPT_PROC_CODE' ) IS NOT NULL
	IF OBJECT_ID( 'DEPT_Actuary_JMarx.dbo.RPT_PROC_CODE' ) IS NOT NULL
		BEGIN
			--TRUNCATE HCI.SUPPORT.RPT_PROC_CODE
			TRUNCATE TABLE DEPT_Actuary_JMarx.dbo.RPT_PROC_CODE;

			--INSERT INTO HCI.SUPPORT.RPT_PROC_CODE
			INSERT INTO DEPT_Actuary_JMarx.dbo.RPT_PROC_CODE
			SELECT
			 [Service Code] =
				PROC_CODE
			,[Service Code Description] =
				proc_desc
			,[Service Code and Description] =
				proc_code_lbl
			,[Procedure Code Family 0] =
				FAMILY0
			,[Procedure Code Family 1] =
				FAMILY1
			,[Procedure Code Family 2] =
				FAMILY2
			,[CCS Description] =
				CCS_DESC
			--INTO
			--HCI.SUPPORT.RPT_PROC_CODE
			--DEPT_Actuary_JMarx.dbo.RPT_PROC_CODE
			FROM
			MedInsight.ASRPT.RPT_PROC_CODE	AS ProcedureCode
		END;

	ELSE
		BEGIN
			SELECT
			 [Service Code] =
				PROC_CODE
			,[Service Code Description] =
				proc_desc
			,[Service Code and Description] =
				proc_code_lbl
			,[Procedure Code Family 0] =
				FAMILY0
			,[Procedure Code Family 1] =
				FAMILY1
			,[Procedure Code Family 2] =
				FAMILY2
			,[CCS Description] =
				CCS_DESC
			INTO
			--HCI.SUPPORT.RPT_PROC_CODE
			DEPT_Actuary_JMarx.dbo.RPT_PROC_CODE
			FROM
			MedInsight.ASRPT.RPT_PROC_CODE	AS ProcedureCode
		END

END



/* FOR DEBUGGING */ --SELECT * FROM DEPT_Actuary_JMarx.dbo.RPT_PROC_CODE
/* FOR DEBUGGING */ --SELECT TOP 100 * FROM HCI.SUPPORT.RPT_PROC_CODE

/**************************************************************************************************************/

COMMIT TRANSACTION

END TRY

BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION --RollBack in case of Error

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    -- Use RAISERROR inside the CATCH block to return error
    -- information about the original error that caused
    -- execution to jump to the CATCH block.
    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );



END CATCH;

END
GO
