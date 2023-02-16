/*

1) Find and replace
	  (?="[0-Z]{5}" to "[0-Z]{5}")
	 \r\n\r\n

2)  Find and replace
	(?<="[0-Z]{5}" to "[0-Z]{5}") ,
	\r\n\r\n

3)  Find and replace
	(?<="[0-Z]{5}") , (?="[0-Z]{5}")
	\r\n

4)  Find and replace
	(?<="[0-Z]{5}") (?!to)
	\r\n\r\n

5)  Find and replace
	(?<! to) (?="[0-Z]{5}")
	\r\n\r\n

6)  Find and replace
	(?<! to) (?="[0-Z]{5}")
	\r\n\r\n

7)	Pick out your relevant code range " to " chunks and paste them appropriately...the next step will erase them

	7a) Find and replace
		\r\n\r\n
		\r\n

	7b) Find and replace
		"
		'

	7c) Find and replace
		to
		AND

8)  Find and replace
	(?<!"[0-Z]{5}")\r\n.*\r\n(?!"[0-Z]{5}")
	\r\n\r\n

9) Find and replace
	"
	'

10) Find and replace
	^'
	,'

*/
