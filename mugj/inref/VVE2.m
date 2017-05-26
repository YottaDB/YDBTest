VVE2	;;TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	W !
	Q
TEX	;
	;
	;
	;
	;
	;                     Validation sequence of Part-III
	;
	;                                                              August 31, 1987
	;                                              COPYRIGHT: MUMPS SYTEM LABORATORY
	;
	;ANSI/MDC X11.1-1984  Validation Suite Version 7.1  Part-III.
	;
	;     The last Test number for Part-III is III-20.
	;
	;Routines contained:
	;Each test routine has 4 different tests with label entry of 1, 2, 3 and 4.
	;
	;    0. VVE ------------- Part-III  Instruction Driver
	;                          VVE is overlaid with VVE1 and VVE2.
	;                          initializing "KILL ^VREPORT"
	;                          and "SET ^VREPORT(0)=0"
	;
	;    1. VVENAK ---------- P.I-12   naked indicator undefined 
	;    2. VVERAND --------- P.I-22   $RANDOM 
	;    3. VVESEL ---------- P.I-22   $SELECT 
	;    4. VVETEXT --------- P.I-22   $TEXT 
	;    5. VVEUNDF --------- P.I-24   undefined variable 
	;    6. VVEDIV ---------- P.I-24   algebraic quotient /
	;    7. VVEPAT ---------- P.I-27   pattern match  intlit1.intlit2
	;    8. VVELINN --------- P.I-32   line references, intexpr<0
	;    9. VVELINA --------- P.I-32   line references, a value of intexpr so large
	;                                  as not to denote a line within the bounds of
	;                                  the given routine
	;   10. VVELINB --------- P.I-32   line references, a spelling of label which
	;                                  does not occur in a defining occurrence
	;                                  in the given routine
	;   11. VVELINXN -------- P.I-32   line reference erroneous for external routine
	;                                  intexpr<0
	;   12. VVELINXA -------- P.I-32   line reference erroneous for external routine
	;                                  a value of intexpr so large as not to 
	;                                  denote a line within the bounds of the given
	;                                  routine
	;   13. VVELINXB -------- P.I-32   line reference erroneous for external routine
	;                                  a spelling of label which does not occur
	;                                  in a defining occurrence in the given routine
	;   14. VVEFORB --------- P.I-36   FOR command, numexpr1:numexpr2:numexpr3
	;                                  and numexpr2>=0 
	;   15. VVEFORC --------- P.I-36   FOR command, numexpr1:numexpr2:numexpr3
	;                                  and numexpr2<0
	;   16. VVEFORD --------- P.I-36   FOR command, numexpr1:numexpr2
	;   17. VVEKILL --------- P.I-39   KILL command, undefined variable
	;   18. VVEREAD --------- P.I-43   READ command, readcount
	;   19. VVELIMS --------- P.III-4  string length
	;   20. VVELIMN --------- P.III-4  integer range
	;   21. VVESTAT ------------------ Report writer for Part-III
	;
