[Member Age On Date of Service] =
	FLOOR( ( CAST( CONVERT( VARCHAR(8),TableAlias.[Date of Service],112 ) AS INT ) - CAST( CONVERT(VARCHAR(8), TableAlias.[Date of Birth],112) AS INT ) ) / 10000 )