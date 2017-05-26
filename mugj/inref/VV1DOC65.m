VV1DOC65	;VV1DOC V.7.1 -65-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-811.1  local branching
	;       I-811.2  overlay with external routine
	;     I-812. FOR command in XECUTE command
	;     I-813. DO command in XECUTE command
	;       I-813.1  local branching
	;       I-813.2  call external routine
	;       I-813.3  call external and local
	;     I-814. QUIT command in XECUTE command
	;     I-815. Nesting of XECUTE command
	;       I-815.1  2 level nesting
	;       I-815.2  3 level nesting
	;       I-815.3  3 level nesting another
	;
	;
	;XECUTE command -2-
	;     (V1XECB)
	;
	;     I-816. DO command in 2 levels nesting of XECUTE command
	;     I-817. GOTO commas in 2 levels nesting of XECUTE command
	;     I-818. QUIT commas in 2 levels nesting of XECUTE command
	;     I-819. FOR command in 2 levels nesting of XECUTE command
	;       I-819.1  without postcondition
	;       I-819.2  with postcondition
	;     I-820. XECUTE a variable whose data value contains KILL of
	;            that variable itself
	;     I-821. XECUTE a variable whose data value contains SETting
	;            the same variable name to a difference value from the
	;            one set to be XECUTE
	;
	;
	;Execution sequence
	;     (V1SEQ)
	;
	;     (V1SEQ is overlaid with V1SEQ1.)
	;
	;     I-788. GOTO and DO
	;     I-789. FOR and DO
	;     I-790. FOR, DO, and GOTO
	;     I-791. FOR, XECUTE, DO, and GOTO
	;       I-791.1  FOR, XECUTE, DO
	;       I-791.2  FOR, XECUTE, GOTO
	;       I-791.3  FOR, XECUTE, QUIT
	;     I-792. FOR, XECUTE, GOTO, and indirection
	;
	;
