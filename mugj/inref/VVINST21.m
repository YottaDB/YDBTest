VVINST21	;Instruction V.7.1 -21-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                   Validation Instruction - Structure Table 
	;
	;
	;Structure Table Part-III of ANSI/MDC X11.1-1984 Validation Suite V.7.1
	;
	;
	;Part-III   Total Items ------------20
	;           Total Tests (visual) ---80 (80 manual/visual)
	;           Total Routines----------80  plus  VVE, VVE1, VVE2 and VVESTAT 
	;
	;
	;main    sub      routine   tests       support        using
	;driver  driver               (visual)   routine(s)     global
	;
	;
	;                   VVE (Instruction Driver) VVE1,-2   ^VREPORT
	;                        initializing "KILL ^VREPORT"
	;                         and "SET ^VREPORT(0)=0"
	;
	;                   VVENAK    4 (   4)                 ^VREPORT,^VVE
	;                   VVERAND   4 (   4)                 ^VREPORT
	;                   VVESEL    4 (   4)                 ^VREPORT
	;                   VVETEXT   4 (   4)                 ^VREPORT
	;                   VVEUNDF   4 (   4)                 ^VREPORT,^VVE
	;                   VVEDIV    4 (   4)                 ^VREPORT
	;                   VVEPAT    4 (   4)                 ^VREPORT
	;                   VVELINN   4 (   4)                 ^VREPORT
	;                   VVELINA   4 (   4)                 ^VREPORT
	;                   VVELINB   4 (   4)                 ^VREPORT
	;                   VVELINXN  4 (   4)   ^VVELINN      ^VREPORT
	;                   VVELINXA  4 (   4)   ^VVELINA      ^VREPORT
	;                   VVELINXB  4 (   4)   ^VVELINB      ^VREPORT
	;                   VVEFORB   4 (   4)                 ^VREPORT
	;                   VVEFORC   4 (   4)                 ^VREPORT
	;                   VVEFORD   4 (   4)                 ^VREPORT
	;                   VVEKILL   4 (   4)                 ^VREPORT,^VVE
	;                   VVEREAD   4 (   4)                 ^VREPORT
	;                   VVELIMS   4 (   4)                 ^VREPORT,^VVE
	;                   VVELIMN   4 (   4)                 ^VREPORT
	;
	;                   VVESTAT (Results Statistics Table) ^VREPORT
	;
	;
	;
	;
	;
	;
