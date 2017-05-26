VVINST4	;Instruction V.7.1 -4-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                               Validation Instruction
	;
	;EXAMINER I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS   ",ITEM W:$Y>55 # Q
	;   S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	;   W !,"           COMPUTER =""",VCOMP,"""" W:$Y>55 #
	;   W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	;   Q
	;   
	;   263 is the digits part of the test ID number.
	;At label 263 the test ID# (I-ID#) and its proposition is printed.
	;Variable ITEM is set to the I-ID# and one of its decomposed proposition.
	;Variable VCOMP is set to the returned value of the executable proposition. 
	;(Variable VCOMP takes gradually more complex combination of the propositions.)
	;
	;  Variable VCORR is set to the correct value for the executed test proposition.
	; D EXAMINER checks the PASS/FAIL status and the result is printed.
	;
	;   At EXAMINER, if VCOMP and VCORR is identical "   PASS" and ID# are output.
	;The PASS count is incremented. If VCOMP and VCORR is not identical "** FAIL" 
	;and ID# are output, and further the VCOMP and VCORR values are output, to 
	;stimulate the analysis of the bug (in the implementation or in the validation).
	;The FAIL count is incremented. 
	;
	;2.3.2   Visual Checking
	;
	;    After  the  Test  ID# and its proposition being printed  there  appears  a 
	;"(visual)" print.  This means that the result must be checked by the  tester's 
	;vision,  namely by seeing at the output result or by checking the time elapsed 
	;on a stop-watch.
	;
	;2.4  Statistic Table
	;
	;    When  coming  to the END of a session (routine),  the test result  of  the 
	;session is tabulated. Examples are given in the "Structure Table".
	;    The  complete  statistics of the result of Part-I and Part-II are  printed 
	;after the Part-I and Part-II. Examples are shown in  this instruction.
	;
	;    The  routine VREPORT has the global (^VREPORT) that contains the  executed 
	;result of each session,  and served to compile a complete statistics report at 
	;the end of the VV1 and VV2 drivers.
	;
	;   6 parameters are transferred from each session to VREPORT.
	;    1)  ROUTINE   Routine name
	;    2)  TESTS     Number of tests to be executed in the routine
	;    3)  AUTO      Number of tests to be auto-checked in the routine
	;    4)  VISUAL    Number of tests to be visual-checked in the routine
	;    5)  PASS      Resulting number of PASSing auto-checks in the routine
