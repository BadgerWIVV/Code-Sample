USE [HCI]
GO

/****** Object:  UserDefinedFunction [dbo].[IsValidNPI]    Script Date: 6/2/2022 4:35:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION  [dbo].[IsValidNPI](@NPI varchar(20))  
RETURNS int AS

/* http://geekswithblogs.net/bosuch/archive/2012/01/16/validating-npi-national-provider-identifier-numbers-in-sql.aspx */

-- Returns 1 for valid or missing NPI 
-- Returns 0 for invalid NPI

-- SELECT [dbo].[IsValidNPI]('1234567893') 
-- SELECT [dbo].[IsValidNPI]('123456789a')

BEGIN 
   Declare @Result int, @Len int, @Index int, @Total int, @TmpStr varchar(2), @TmpInt int 
   Set @Result = 0 
   Set @Total = 0 
   Set @NPI = IsNull(@NPI,'') 
   Set @Len = Len(@NPI)

   If @Len = 0 
      Set @Result = 1 
   Else 
   Begin 
      If @Len <> 10 or IsNumeric(@NPI) = 0 or @NPI like '%.%' or (@NPI not like '1%' and @NPI not like '2%')
         Set @Result = 0 
      Else 
      Begin 
         Set @Index = @Len

         While @Index > 1 
         Begin 
            Set @TmpStr = Substring(@NPI, @Index, 1) 
            Set @Total = @Total + Cast(@TmpStr as int)

            Set @TmpStr = SubString(@NPI, @Index-1, 1) 
            Set @TmpInt = Cast(@TmpStr as int) * 2 
            If @TmpInt < 10 
               Set @Total = @Total + @TmpInt 
            Else 
            Begin 
               Set @TmpStr = Cast(@TmpInt as varchar(2)) 
               Set @Total = @Total + Cast(Substring(@TmpStr,2,1) as int) 
               Set @Total = @Total + Cast(Substring(@TmpStr,1,1) as int) 
            End 
            Set @Index = @Index - 2 
         End

         If @Len % 2 = 1 
            Set @Total = @Total + Cast(Substring(@NPI,1,1) as int) 
         If @Len = 10 
            Set @Total = @Total + 24

         If @Total % 10 = 0 
            Set @Result = 1 
         Else 
            Set @Result = 0 
      End 
   End 
   Return(@Result) 
END;
GO


