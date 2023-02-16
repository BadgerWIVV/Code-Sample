USE Database;
GO

IF OBJECT_ID( 'Database.dbo.test' ) IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.test
	END;
GO


CREATE PROCEDURE dbo.test (
@XML		XML		OUTPUT
)
AS 
BEGIN

SELECT [AnotherRow_1] = 42 INTO #Table1
SELECT [Row_1] = 29, [Row_2] = 3 INTO #Table2

 -- here you render your 2 tables containing useful data as XML
  declare @Table1Xml xml = (
    select [AnotherRow_1]
    from #Table1 as TableOutput1
    for xml auto)

  declare @Table2Xml xml = (
    select [Row_1], [Row_2]
    from #Table2 as TableOutput2
    for xml auto)

  -- here you build a single XML with all the data required
  set @xml = 
    cast(@Table1Xml as nvarchar(max)) + 
    cast(@Table2Xml as nvarchar(max))

END

declare @xml xml
--exec GetBlogWithDetailsXml 1, @xml output


EXEC test @xml output 


select [Raw XML Output] =
	@xml




select
  Col.value('@AnotherRow_1', 'int') as [Row 1]
from @xml.nodes('/TableOutput1') as Data(Col)

select
  Col.value('@Row_1', 'int') as [Row 1],
  Col.value('@Row_2', 'int') as [Row 2]
from @xml.nodes('/TableOutput2') as Data(Col)


IF OBJECT_ID( 'Database.dbo.test' ) IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.test
	END;
GO
