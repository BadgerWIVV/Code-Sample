USE [HCI]
GO

/****** Object:  UserDefinedFunction [dbo].[AverageBloodPressure]    Script Date: 6/2/2022 4:35:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[AverageBloodPressure](
 @Measure1		AS INT
,@Measure2		AS INT
,@Measure3		AS INT
)

--RETURNS NUMERIC(19,4)
RETURNS INT

AS
BEGIN

DECLARE
@Counter	NUMERIC(19,4) = 0.00;

IF @Measure1 IS NOT NULL  BEGIN SET @Counter = @Counter + 1 END
IF @Measure2 IS NOT NULL  BEGIN SET @Counter = @Counter + 1 END
IF @Measure3 IS NOT NULL  BEGIN SET @Counter = @Counter + 1 END

	RETURN
	CASE
		WHEN @Counter = 0 THEN NULL
		ELSE ROUND( ( ISNULL( @Measure1, 0 )+ ISNULL( @Measure2, 0 ) + ISNULL( @Measure3, 0 ) ) / @Counter, 0 )
	END
END;

GO


