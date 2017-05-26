VVINST2	;Instruction V.7.1 -2-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Instruction
	;
	;    Special warning is that V1GVN in the Part-I tests 6 global variable  names 
	;starting with the character "%" (^%,  ^%ABCDEF,  ^%1234, ^%A1, ^%ABC456GH, and 
	;^%1Z2Y3Z)  by SETting and KILLing.   If the system being tested is going to be 
	;seriously  affected by being KILLed for the global name,  change the lines  of 
	;V1GVN in question as a comment line.
	;
	;
	;1.3  How to evaluate the results of the tests changed to "comment lines"
	;
	;    The  tests for the "%"-lead routine names or "%"-lead global  names,  when 
	;the  lines including these tests are changed as "comment lines,   will not  be 
	;executed.   The tester should remember these routines, since the tests will be 
	;reported in the report writer as "aborted!",   so that the tester should alter 
	;the results manually as "PASS" numbers, instead of "aborted!" numbers.
	;
	;    "Aborted!" reflects in the report that the system stopped by an error, and 
	;the  tester  is  responsible to describe the "error message"  the  system  has 
	;output when it stops, when the statistic report is to be compiled. When a test 
	;is  artificially  by-passed,  the "aborted!" report should be  corrected  with 
	;confirmation.
	;
	;
	;2. How to run the Validation Suite V.7.1
	;
	;2.1  Validation Flow
	;
	;    The complete validation consists of Part-I, Part-II, and Part-III, to be 
	;executed in that order.  Part-I and Part-II is automatically driven while  the 
	;results  are recorded in the database for later report writing.   Part-III  is 
	;the tests if the system correctly stops with ERROR messages,  so that the test 
	;routines should be invoked manually.
	;
	;    The  report  writer  tabulates at the end of each  session  (routine)  the 
	;summary of the tests in that session.
	;
	;    At  the  end  of Part-I,  and Part-II,  the report  writer  tabulates  the 
	;statistics of the test results against the sessions. The report writer for the 
	;Part-III has a different construction from that for the Part-I and -II.
	;
	;    Part-I  and -II are intended not to stop by error during execution, except 
	;in the routines where the terminal awaits the tester to input some message  by 
	;the request from the computer. It is desirable for the tester not to leave the 
	;site  of testing.  Part-III is intended for the computer to stop by  executing 
	;the  test  each time,  not by a permanent loop but by  writing  error messages.
	;
