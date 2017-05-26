VVOVER5	;Overview V.7.1 -5-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;(revision at ANSI) it was made to stay at the original site without executable
	;test, but with the date of nullification, not to be replaced by other test, 
	;thus keeping the track of evolving. If a newly added test is to be ID-numbered,
	;it must take a new number regardless of the site of its insertion. 
	;
	;   The document of the Validation Suite has the statements as "The last test 
	;number of Part-I is I-847",  denoting that the most recently created test  is 
	;"I-847" which will be found somewhere in the routines with a new proposition. 
	;This forces the next added test to take the number "I-848". 
	;
	;
	;5. Evaluation of Results
	;
	;   Except for the Part-III, results of the validation are checked for 
	;"passing" or "failing" for the effective tests. Automatic detection attaches 
	;"PASS" or "**FAIL" mark at the top of the effective individual tests on the 
	;reporting paper (or CRT) during execution. 
	;   These are automatically sorted in the database. The report writer has the 
	;existing numbers of tests, including 72 tests in the Part-I and -II which must
	;be evaluated "visually". 
	;   The frequencies for "passing",  "failing",  and "aborted", are automatically
	;detected, while  providing blanks to be filled manually after visual detection 
	;of the results.  
	;   During execution of the routines,  "passing" tests are printed with  "PASS"
	;sign  followed by the ID# and the proposition.  "Failing" tests are  reported 
	;with  "**FAIL" signs followed by the IDs and the proposition.  The basis  for 
	;detection  as  "failure" is reported with comparison of the computed  against 
	;the correct results.  For the tests which have "PASS"ed, it is unnecessary to 
	;report why they passed the tests. 
	;
	;   For the tests of Part-I and II, "error" interruptions without rendering 
	;values are counted as "aborted".  Numbers  of "aborted" tests are 
	;automatically reported. "Aborted" tests will be counted as "failures", but if 
	;the interruption has been made by human error, the routine may be restarted by
	;typing "DO test-number^routine-name". The Structure Table of the routines would
	;provide support for the validation process.  
	;
	;   Part-III tests the system's responses for the syntaxes specified in the 
	;ANSI/MDC X11.1-1984 as erroneous syntaxes.  Undetected error or system hung-ups
	;at each test is to be evaluated as failures. Each routine has 4 tests with 
	;labels 1, 2, 3, and 4. These should be manually invoked after each stop. 
	;
	;   Illustrations of the reports in the Overview and Instruction pages show how
	;the execution would automatically, visually/ and manually produce the 
	;validation reports for the evaluation of the entire validation results. 
	;
	;6. Coverage and Limitation of, and Benefits from the Validation Tests
