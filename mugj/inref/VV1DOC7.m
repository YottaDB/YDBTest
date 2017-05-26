VV1DOC7	;VV1DOC V.7.1 -7-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-607.5  12345
	;       I-607.6  000000
	;       I-607.7  0000001
	;       I-607.8  12345678
	;     I-608. label is combination of alpha and digit
	;       I-608.1  A1B2C3
	;       I-608.2  A1BCDE
	;       I-608.3  A1234B
	;     I-610. maximum length of label
	;       I-610.1  88888888
	;       I-610.2  %AB777Z0
	;
	;
	;Preliminary test of GOTO, DO, QUIT command
	;     (V1PRGD)
	;     (V1PRGD is overlaid with V1PRGD1, V1PRGD2 and V1PRGD3.)
	;
	;     I-726. GOTO label
	;       I-726.1  ABCD
	;       I-726.2  3
	;       I-726.3  FOUR4
	;     I-727. DO label
	;     I-729. termination of DO command by explicit QUIT
	;     I-730. termination of DO command by implicit QUIT
	;       I-727/729/730.1  2; explicit quit
	;       I-727/729/730.2  YOU; explicit quit
	;       I-727/729/730.3  SIX66; implicit quit
	;     I-728. DO ^routineref
	;     I-729. termination of DO command by explicit QUIT
	;     I-730. termination of DO command by implicit QUIT
	;       I-728/729/730.1  ^V1PRGD1; explicit quit
	;       I-728/729/730.2  ^V1PRGD2; implicit quit
	;       I-728/729/730.3  ^V1PRGD3; implicit quit
	;
	;
	;Routine name
	;     (V1RN)
	;     (V1RN is overlaid with V0, V01, V012, V4444, V12345, V000006, V7777777,
	;      V, VA, VAB, VABC, VABCD, VABCDE, VABCDEF, VABCDEFG, VABCDEFH, %, %1A,
	;      %2345678 and %BCDEFGH.)
	;
	;     I-776. routinename is "%"
	;     I-777. routinename is "%" followed by alpha and digit
	;     I-778. routinename is alpha
	;     I-779. routinename is alpha followed by digits
