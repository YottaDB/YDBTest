VVINST6	;Instruction V.7.1 -6-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Instruction
	;
	;
	;    All the sequence of the executed routines would be reported.
	;
	;
	;2.5.3  Running Validation without Statistics Report
	;
	;    As  both  the drivers VV1 and VV2 initialize the  report  writer,  running 
	;validation   without   statistics   reports  is  possible  by   avoiding   the 
	;initialization of the report writer.
	;
	;  KILL ^VREPORT 
	;  DO V1WR^VV1   (instead of DO ^VV1 for running the Part-I)
	;  DO VV2CS^VV2  (instead of DO ^VV2 for running the Part-II)
	;
	;    For  running  a set of sessions without statistics  reports,  execute  the 
	;following only once. Any numbers of sessions would be without statistics, 
	;until the tests are executed via the VV1 or VV2.
	;
	;  KILL ^VREPORT
	;
	;2.6.  Execution of Part-III
	;
	;   Part-III validates the "error" checking capabilities for the explicitly 
	;specified items in the ANSI/MDC X11.1-1984. The items are 20 in total, and 4 
	;tests are incorporated in each of the 20 routines (VVE**). The instruction 
	;routine VVE does not control the execution flow of Part-III, but displays
	;the steps for validation to be followed. VVESTAT is the routine for writing 
	;the report for Part-III, some part of which could be automatic if error 
	;detection fails at certain points.
	;
	;   For running a desired set of sections of Part-III, without running the VVE 
	;instruction driver, Statistics Report may be obtained by first setting, 
	;
	; KILL ^VREPORT
	; SET ^VREPORT(0)=0
	;
	;then after running a set of sections
	;
	; DO ^VVESTAT
	;
	;   The complete form of Part-III's Result Statistics Table is shown at the end 
	;of this instruction.
	;
	;
	;
