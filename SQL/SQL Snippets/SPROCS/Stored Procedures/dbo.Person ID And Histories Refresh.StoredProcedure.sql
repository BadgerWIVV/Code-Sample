USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[Person ID And Histories Refresh]    Script Date: 1/20/2020 9:54:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Person ID And Histories Refresh]

AS

/**********************************************************************************/
/* DECLARE INITIAL PARAMETERS FOR THE TRANSACTION LOG */

DECLARE 
 @TransactionName			VARCHAR(1000) = ( '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME( @@PROCID ) + '].[' + OBJECT_NAME( @@PROCID ) + ']')
,@TransactionDescription	VARCHAR(1000) = 'Execute the PersonID SP and all the Person History SPs';

/*************************************************************************************************************************/
/*ADD A ROW TO THE TRANSACTION LOG*/

EXEC DEPT_Actuary_JMarx.dbo.[TransactionLogInsert]  @TransactionDescription = @TransactionDescription
	,@TransactionStatus = 'Executed'
	,@TransactionComment = 'The procedure to execute the PersonID SP and all the Person History SPs was executed. Success/Failure/Error state unknown.'
	,@TransactionName =  @TransactionName

/*****************************************************************************************************************************/

EXEC DEPT_Actuary_JMarx.[dbo].[PersonID]

EXEC DEPT_Actuary_JMarx.[dbo].[PersonID - Charlson Comorbidity History]
EXEC DEPT_Actuary_JMarx.[dbo].[PersonID - Elixhauser Comorbidity History]

EXEC DEPT_Actuary_JMarx.[dbo].[PersonHistory_Back_Pain]
EXEC DEPT_Actuary_JMarx.[dbo].[PersonHistory_Cancer]
EXEC DEPT_Actuary_JMarx.[dbo].[PersonHistory_Drug_Testing]
EXEC DEPT_Actuary_JMarx.[dbo].[PersonHistory_Emergency_Room]
EXEC DEPT_Actuary_JMarx.[dbo].[PersonHistory_Evaluation_and_Management]
EXEC DEPT_Actuary_JMarx.[dbo].[PersonHistory_Home_Health]
EXEC DEPT_Actuary_JMarx.[dbo].[PersonHistory_Hospice]
EXEC DEPT_Actuary_JMarx.[dbo].[PersonHistory_Inpatient]
EXEC DEPT_Actuary_JMarx.[dbo].[PersonHistory_Opioids]
EXEC DEPT_Actuary_JMarx.[dbo].[PersonHistory_Residential_Treatment_Facilities]
EXEC DEPT_Actuary_JMarx.[dbo].[PersonHistory_Skilled_Nursing_Facilities]
EXEC DEPT_Actuary_JMarx.[dbo].[PersonHistory_Substance_Abuse]

GO
