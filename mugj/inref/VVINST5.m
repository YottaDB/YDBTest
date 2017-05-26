VVINST5	;Instruction V.7.1 -5-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Instruction
	;
	;
	;    6)  FAIL      Resulting number of FAILing auto-checks in the routine
	;where,
	;
	;     TESTS=AUTO+VISUAL
	;     If AUTO=0, the PASS and FAIL are not transferred to VREPORT.
	;     "aborted!" is calculated as AUTO-PASS-FAIL.
	;
	;
	;2.5  Printing the Part Statistics Table
	;
	;2.5.1  Repeated Printings of the Part Statistics Table
	;
	;   Although drivers, VV1 and VV2, are made to automatically write session 
	;statistics reports and the part statistics report, the part statistics can be 
	;repeatedly printed after completing the VV1 or VV2 for the Part-I or Part-II, 
	;respectively.  For the required repeated print out, 
	;
	;  DO STATIS^VREPORT
	;
	;is the instruction. This instruction would be convenient when the tester 
	;wishes to make another copy on a different sheet.  Remember that this repeated 
	;printing  of  the part statistics table is not applicable for the  Part-I  and 
	;Part-II at the same time. See the "Structure Table" for the sample of the part 
	;statistics table.   Part-III has the report writer VVESTAT for which initial 
	;value is set by the instruction driver VVE, or separately when needed.
	;
	;2.5.2  Statistics for the selected set of sessions
	;
	;    If  the  statistics tables are desired for any set of  selected  sessions, 
	;without  running them via the VV1 or VV2,  execute the following two  commands 
	;only once before running the set of sessions.
	;
	;  KILL ^VREPORT            ; existing variable ^VREPORT is deleted.
	;  SET ^VREPORT(0)=0        ; "executed order" is set to 0.
	;
	;    After these two commands,  session statistics is printed immediately after 
	;each session.  If the same session is repeatedly executed,  the executed order 
	;will be incremented with the same routine name.  After running all the desired 
	;sessions,  the  total  statistics  would be printed as in  the  form  of  Part 
	;Statistics Table, by executing the following command.
	;
	;  DO STATIS^VREPORT
	;
