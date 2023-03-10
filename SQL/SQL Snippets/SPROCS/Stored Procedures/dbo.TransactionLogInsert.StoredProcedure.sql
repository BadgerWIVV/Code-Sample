USE [DEPT_Actuary_JMarx]
GO
/****** Object:  StoredProcedure [dbo].[TransactionLogInsert]    Script Date: 1/20/2020 9:54:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TransactionLogInsert] 
 @TransactionDescription		VARCHAR(1000) = NULL
,@TransactionStatus				VARCHAR(50)  = NULL
,@TransactionComment			VARCHAR(1000)  = NULL 
,@TransactionName				VARCHAR(1000)

AS

BEGIN

DECLARE
 @UserName					VARCHAR(50)
,@TransactionDate				DATE;


SET
 @UserName = ( SELECT CURRENT_USER );

SET
 @TransactionDate = ( SELECT CAST( GETDATE() AS DATE ) );

--SET
-- @TransactionName = ( SELECT OBJECT_NAME(@@PROCID) );


INSERT INTO
DEPT_Actuary_JMarx.dbo.[Transaction Log]
SELECT
 [Transaction Date] =
	@TransactionDate
,[Name] =
	@TransactionName
,[Description] =
	@TransactionDescription
,[Status] = 
	@TransactionStatus
,[Comment] =
	@TransactionComment
,[User Name] =
	@UserName


END
GO
