/* 
1) Assume we have a nice list of data from Excel that we need to put into SSMS
*/

J0256
J0256
J0256
J0517
J0517
J0885
J0885
J0897
J0897
J1325
J1325
J1569
J1569
J2505
J2505
J3357
J3357
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3590
J3590
J3590
J3590
J3590
J3590
J3590
J7321
J7321
J7325
J7325
J8499
J8499
J8499
J8499
J8499
J9035
J9035
J9217
J9217
Q5111
Q5111
Q5113
Q5113
Q5114
Q5114

/*
2) We want it to look like this: 
*/


(
 'J0256'
,'J0256'
,'J0256'
,'J0517'
,'J0517'
,'J0885'
,'J0885'
,'J0897'
,'J0897'
,'J1325'
,'J1325'
,'J1569'
,'J1569'
,'J2505'
,'J2505'
,'J3357'
,'J3357'
,'J3490'
,'J3490'
,'J3490'
,'J3490'
,'J3490'
,'J3490'
,'J3490'
,'J3490'
,'J3490'
,'J3490'
,'J3490'
,'J3490'
,'J3490'
,'J3490'
,'J3490'
,'J3490'
,'J3590'
,'J3590'
,'J3590'
,'J3590'
,'J3590'
,'J3590'
,'J3590'
,'J7321'
,'J7321'
,'J7325'
,'J7325'
,'J8499'
,'J8499'
,'J8499'
,'J8499'
,'J8499'
,'J9035'
,'J9035'
,'J9217'
,'J9217'
,'Q5111'
,'Q5111'
,'Q5113'
,'Q5113'
,'Q5114'
,'Q5114'
)

/* 
3) If we want to use in an IN statement, we will need to comma separate and encapsulate in single quotes.
This could be done in Excel using formulas
OR
we can use Find and replace with regular expressions!

Let's try out find and replace:
A) Highlight the list past the comment.
B) Open the find and replace window ( Ctrl + H )
C) Ensure that the .* option is selected to allow for regular expressions AND that the replace parameter is limited to the Selection (see bottom right)
D) We don't want to replace any data, but there is a line break/carriage return that we can take advantage of.  If we can replace the return with extra characters and the return, we can add our commas and quotes as we need.
	-We want to find the returns, use the regular expression \r\n to find the return/new line
	-\r\n should be in the first search box
E) Add our commas and quotes
	-'\r\n,' should be in the second replace box
F) Replace all (Alt +A )
G) Modify the first and last entries to add () and add/remove leading/trailing commas
*/
J0256
J0256
J0256
J0517
J0517
J0885
J0885
J0897
J0897
J1325
J1325
J1569
J1569
J2505
J2505
J3357
J3357
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3490
J3590
J3590
J3590
J3590
J3590
J3590
J3590
J7321
J7321
J7325
J7325
J8499
J8499
J8499
J8499
J8499
J9035
J9035
J9217
J9217
Q5111
Q5111
Q5113
Q5113
Q5114
Q5114