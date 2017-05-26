VVINST1	;Instruction V.7.1 -1-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                    ANSI/MDC X11.1-1987 Validation Instruction
	;
	;                                                            August 31, 1987
	;                                           Copyright: MUMPS System Laboratory
	;
	;
	;Instructions for executing Validation Suite V.7.1
	;
	;1. Requirements prior to installing the suite.
	;
	;1.1  Routines existing in the system being tested
	;
	;   Before loading the  Suite on the disk, the following must be confirmed.
	;
	;    Examine whether the system manager has conditioned the system prohibitive 
	;for  any  specific routine names,  and check against the routine names in the 
	;Validation  Suite to be installed, together with the global names used in the 
	;validation routines, written in the "Structure Tables" to be found in this 
	;Instruction. 
	;
	;    In  the  Validation Suite Part-I,  the routine V1RN references  4  routine 
	;names  lead  by  a "%".   Set aside any conflicting routines existing  in  the 
	;system,  or  if it is problemsome put a comment sign ";" at the start  of  the 
	;lines in the routine V1RN that reference the "%"-lead system routines. 
	;Check  also  the 16 other routine names being referenced from V1RN  (V0,  V01, 
	;V012, etc.) lest the system to be tested should not be affected during loading 
	;the suite.
	;
	;    Except  these  20 routine names which are called in the  external  routine 
	;reference  tests,  the routines essential for validation start with  the  "V1" 
	;characters.   The  report writer has the routine name VREPORT.   There are 192 
	;routines used in Part-I execution including VREPORT.   VV1 is the main  driver 
	;for the Part-I.
	;    In the Validation Suite Part-II, all the routines start with the "VV2" 
	;characters. Exception is the report writer VREPORT (common with Part-I).
	;    There are 22 routines used in Part-II execution including VREPORT.
	;    VV2 is the main driver for the Part-II.
	;    Part-III  is entered from VVE which is not a driver but an instruction  to 
	;be followed during manual execution of Specified Error Checkers.
	;
	;
	;1.2  Globals existing in the system being tested
	;
	;    Before  executing the Validation Suite,  confirm that the existing globals 
	;in the system is not affected by the KILLings and SETtings of global variables 
	;by the Validation Suite. The global variable names referenced are shown in the 
	;"Structure Table".
