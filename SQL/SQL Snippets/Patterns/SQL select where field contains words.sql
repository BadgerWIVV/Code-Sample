/* https://stackoverflow.com/questions/14290857/sql-select-where-field-contains-words */

USE HCI_Stage;
GO

 CREATE FUNCTION [dbo].[fnSplit] ( @sep CHAR(1), @str VARCHAR(512) )
 RETURNS TABLE AS
 RETURN (
           WITH Pieces(pn, start, stop) AS (
           SELECT 1, 1, CHARINDEX(@sep, @str)
           UNION ALL
           SELECT pn + 1, stop + 1, CHARINDEX(@sep, @str, stop + 1)
           FROM Pieces
           WHERE stop > 0
      )

      SELECT
           pn AS Id,
           SUBSTRING(@str, start, CASE WHEN stop > 0 THEN stop - start ELSE 512 END) AS Data
      FROM
           Pieces
 );
 GO


 DECLARE @FilterTable TABLE (Data VARCHAR(512))

 INSERT INTO @FilterTable (Data)
 SELECT DISTINCT S.Data
 FROM fnSplit(' ', 'word1 word2 word3') S -- Contains words

 SELECT DISTINCT
      T.*
 FROM
      MyTable T
      INNER JOIN @FilterTable F1 ON T.Column1 LIKE '%' + F1.Data + '%'
      LEFT JOIN @FilterTable F2 ON T.Column1 NOT LIKE '%' + F2.Data + '%'
 WHERE
      F2.Data IS NULL