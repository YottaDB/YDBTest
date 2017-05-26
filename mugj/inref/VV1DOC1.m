VV1DOC1	;VV1DOC V.7.1 -1-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;                                                                August 31, 1987
	;                                              COPYRIGHT: MUMPS SYSTEM LABORATORY
	;
	;ANSI/MDC X11.1-1984  Validation Suite Version 7.1 Part-I
	;
	;     The last Test number for Part-I is I-847.
	;
	;
	;1) Routines contained
	;
	;      0. VV1 ------- Main Driver Part-I
	;
	;   Preliminary tests
	;
	;      1. V1WR ------ Write all characters
	;      2. V1CMT ----- Comment
	;      3. V1LL1 ----- Line label -1-
	;      4. V1LL2 ----- Line label -2-
	;      5. V1PRGD ---- Preliminary test of GOTO and DO
	;                       V1PRGD is overlaid with V1PRGD1, V1PRGD2 and V1PRGD3.
	;      6. V1RN ------ Routine name
	;                       V1RN is overlaid with V0, V01, V012, V4444, V12345
	;                       V000006, V7777777, V, VA, VAB, VABC, VABCD, VABCDE
	;                       VABCDEF, VABCDEFG, VABCDEFH, %, %1A, %2345678
	;                       and %BCDEFGH.
	;      7. V1PRSET --- Preliminary test of SET
	;      8. V1PRIE ---- Preliminary test of IF and ELSE
	;      9. V1PRFOR --- Preliminary test of FOR
	;     10. V1NUM ----- Sub driver
	;     11. V1NUM1 ---- Numeric literal -1-
	;     12. V1NUM2 ---- Numeric literal -2-
	;     13. V1NUM3 ---- Numeric literal -3-
	;     14. V1NUM4 ---- Numeric literal -4-
	;     15. V1FC ------ Sub driver
	;     16. V1FC1 ----- Format control characters -1-
	;     17. V1FC2 ----- Format control characters -2-
	;
	;   Main tests
	;
	;     18. V1UO ------ Sub driver
	;     19. V1UO1A ---- Unary operator -1-   +
	;     20. V1UO1B ---- Unary operator -2-   +
	;     21. V1UO2A ---- Unary operator -3-   -
	;     22. V1UO2B ---- Unary operator -4-   -
	;     23. V1UO3A ---- Unary operator -5-   '
