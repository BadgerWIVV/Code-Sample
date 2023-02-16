/* recursive CTE */
WITH #t AS (
  SELECT [v] = 1     -- Seed Row
  UNION ALL
  SELECT [v] + 1 -- Recursion
  FROM #t
)

SELECT TOP 1000
[v]
FROM
#t
OPTION (MAXRECURSION 1000)