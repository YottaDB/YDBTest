VVINST3	;Instruction V.7.1 -3-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Instruction
	;
	;  Entrance to Part-I is via the main driver VV1 (DO ^VV1).
	;  Entrance to Part-II is via the main driver VV2 (DO ^VV2).
	;  Entrance to Part-III is via the instruction driver VVE (DO ^VVE)
	;
	;
	;2.2  How to resume the execution flow after meeting an error stop
	;
	;    When  encoutering an error stop during the execution of Part-I or Part-II, 
	;the best way to resume the execution is to print the current routine and  find 
	;where it stopped and where it could be started immediately following the error 
	;producing command line.
	;
	;    In many cases, the immediate following test number after the current test 
	;number is the one to resume the normal exucetion flow. If the error occurred 
	;at the test number I-10, "DO 11^V1AC2" would restart the test. This method, 
	;however, is not always reliable. The best way is to confirm in the routine in 
	;execution directly.  Execution sequence of the routines will be found in the 
	;"Structure Table" and "Validation Content". Still the entry point should be 
	;directly confirmed in the routine itself. Even if the error stop occurs at the 
	;last test in the session, do not let the control return to the main driver, but
	;let the label "END" be executed  where the result of  the session is to be 
	;reported.  Otherwise the session report will not be written. 
	;
	;
	;2.3  Methods of Test Result Checking
	;
	;   There are two result checking methods applied in the Validation Suite V.7.1.
	;One is automatic check and another is visual check. Automatic check is applied 
	;whenever  the  execution  of test returns some value in the  system  which  is 
	;compared  with  the  correct  value in the system by  using  a  string  binary 
	;operator  "=".   Visual  check is applied whenever the result behavior of  the 
	;test cannot be detected in the system as the test for the WRITE command.
	;
	;2.3.1  Automatic Checking
	;
	; Sample: V1FNE1
	;
	;236 W !,"I-236  expr1 is a string literal"
	;    S ITEM="I-236  " S VCOMP=$E("ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789",26)
	;    S VCORR="Z" D EXAMINER
	;    ;
	;264 W !,"I-264  expr1 is a positive integer"
	;    S ITEM="I-264  " S VCOMP="$E(000789400,3) S VCORR="9" D EXAMINER
	;    ;
	;    ;
