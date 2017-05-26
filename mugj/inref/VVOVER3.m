VVOVER3	;Overview V.7.1 -3-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;   The  Part-I has its driver (VV1) which controls the flow of  routines  to 
	;the end of the Part-I.   After each session of the routines, there is printed 
	;a  summary of the number of tests engaged,  the number of passing tests,  the 
	;number  failing  tests,  the numbers of tests to be  visually  confirmed  for 
	;failure or success, and the number of tests which have not been done by some 
	;cause (mostly error) that must be confirmed visually for their failing or need
	;for being tried again. 
	;
	;   The Part-II has its driver (VV2).  It should be executed after the Part-I 
	;is  completed  and after the summary of the results of validation  of  Part-I 
	;which is very large has been printed.  VV2 controls the flow of Part-II until
	;the summary of the results of Part-II testings are tabulated. 
	;
	;   The Part-III has its instruction driver (VVE) which also sets up the initial
	;values for the Statistics Report. It instructs how to invoke the series of 
	;tests. The operator should carefully check the results of each test, as 
	;"error-checking" mechanism may differ among implementations; some working 
	;during execution and others during routine pre-compilation.
	;The Report Form of the tests is tabulated after completion of the Part-III. 
	;
	;
	;4.  Content of the Tests and their Structure 
	;
	;   A session title (title of routine) always leads a series of tests. The 
	;numbers of routines and associated session titles have increased while programs
	;were added or splitted being necessitated by the restriction in the size of a 
	;routine (Portability Requirement). However, the total ID numbers of parent 
	;tests have been kept unchanged to the advantage of maintainability, unless a 
	;uniquely new test with its new ID number with a new proposition has been added.
	;
	;   A section title with or without ID number may precede a series of tests.
	;ID numbers of the tests are represented by integers lead by the Part number. 
	;Sometimes the ID number of a test has series of child ID's, of which integers 
	;follow a dot (.) after the parent ID number, or even grandchild ID's with 
	;integers following after a second dot. Thus the child and grandchild tests are
	;the component of the parent and the child tests, respectively. Any failure in 
	;the child tests would be counted as a problem in the parent test. Similarly, 
	;failures in the grandchild tests are counted as the problems in the child test.
	;The extent of the failures in the family structured tests would pin point the  
	;site and the depth of problems in the parent test.
	;
	;   Part-III validation items are printed with the page and the phrase number 
	;followed by the specification document clarifying the error status. Each error
	;status is checked by 4 different programs. 
	;
	;
	;4.1 Illustrations of structures:
