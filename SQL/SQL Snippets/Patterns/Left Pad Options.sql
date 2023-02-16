/**************************************************************************************************************/
/* Options to pad strings with preceding characters */

/*
From: Michael Maldonado 
Sent: Monday, January 09, 2017 2:45 PM
To: Jared Marx <JMarx@weatrust.com>
Subject: RE: ENCRYPT: TIN as numeric, leading zeroes truncated

Format is good, too.  Won’t work pre SQL Server 2012, but probably best for 2012+

From: Jared Marx 
Sent: Monday, January 09, 2017 1:39 PM
To: Michael Maldonado <MMaldonado@weatrust.com>
Subject: RE: ENCRYPT: TIN as numeric, leading zeroes truncated

I think I might like FORMAT(@Number,'00000000#') the best:


*/
DECLARE 
 @Number FLOAT   = 568
,@Width INT     = 9
,@Pad   CHAR(1) = '0';

SELECT 
 [Format] = FORMAT(@Number,'00000000#')
,[Replace] = REPLACE( STR( @Number,@Width),' ', @Pad)
,[Replicate] = REPLICATE( @Pad, @Width-LEN( CONVERT( VARCHAR( 100 ), @Number ) ) ) + CONVERT(VARCHAR(100),@Number)
,[Right] = RIGHT( REPLICATE( @Pad, @Width ) + CAST( @Number AS VARCHAR( 9 )), @Width);
GO

DECLARE 
 @Number FLOAT   = -1.234
,@Width INT     = 9
,@Pad   CHAR(1) = '0';

SELECT 
 [Format] = FORMAT(@Number,'00000000#')
,[Replace] = REPLACE( STR( @Number,@Width),' ', @Pad)
,[Replicate] = REPLICATE( @Pad, @Width-LEN( CONVERT( VARCHAR( 100 ), @Number ) ) ) + CONVERT(VARCHAR(100),@Number)
,[Right] = RIGHT( REPLICATE( @Pad, @Width ) + CAST( @Number AS VARCHAR( 9 )), @Width);
GO

DECLARE 
 @Number FLOAT   = 3
,@Width INT     = 9
,@Pad   CHAR(1) = '0';

SELECT 
 [Format] = FORMAT(@Number,'00000000#')
,[Replace] = REPLACE( STR( @Number,@Width),' ', @Pad)
,[Replicate] = REPLICATE( @Pad, @Width-LEN( CONVERT( VARCHAR( 100 ), @Number ) ) ) + CONVERT(VARCHAR(100),@Number)
,[Right] = RIGHT( REPLICATE( @Pad, @Width ) + CAST( @Number AS VARCHAR( 9 )), @Width);
GO

DECLARE 
 @Number FLOAT   = 123456789
,@Width INT     = 9
,@Pad   CHAR(1) = '0';

SELECT 
 [Format] = FORMAT(@Number,'00000000#')
,[Replace] = REPLACE( STR( @Number,@Width),' ', @Pad)
,[Replicate] = REPLICATE( @Pad, @Width-LEN( CONVERT( VARCHAR( 100 ), @Number ) ) ) + CONVERT(VARCHAR(100),@Number)
--,[Right] = RIGHT( REPLICATE( @Pad, @Width ) + CAST( @Number AS VARCHAR( 9 )), @Width);
GO

DECLARE 
 @Number FLOAT   = 0
,@Width INT     = 9
,@Pad   CHAR(1) = '0';

SELECT 
 [Format] = FORMAT(@Number,'00000000#')
,[Replace] = REPLACE( STR( @Number,@Width),' ', @Pad)
,[Replicate] = REPLICATE( @Pad, @Width-LEN( CONVERT( VARCHAR( 100 ), @Number ) ) ) + CONVERT(VARCHAR(100),@Number)
,[Right] = RIGHT( REPLICATE( @Pad, @Width ) + CAST( @Number AS VARCHAR( 9 )), @Width);
GO
