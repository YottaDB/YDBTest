VVINST19	;Instruction V.7.1 -19-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                   Validation Instruction - Structure Table
	;
	;
	;Structure Tables of ANSI/MDC X11.1-1987 Validation Suite Version 7.1
	;
	;
	;Part II  Total Items ------------  181
	;         Total Tests (visual) ---  210 (  4)
	;         Total Routine ----------  21 and VREPORT
	;
	;
	;main    sub      routine   tests       support        using
	;driver  driver               (visual)   routine(s)     global
	;
	;
	; VV2                                                  ^VREPORT
	;  |
	;  +--------------- VV2CS     8 (   0)   VREPORT       
	;  +--------------- VV2LCC1  10 (   4)   VREPORT       
	;  +--------------- VV2LCC2  10 (   0)   VREPORT       
	;  +--------------- VV2LCF1  18 (   0)   VREPORT       
	;  +--------------- VV2LCF2  18 (   0)   VREPORT       
	;  +--------------- VV2FN1   14 (   0)   VREPORT       ^VV
	;  +--------------- VV2FN2   14 (   0)   VREPORT       
	;  +--------------- VV2LHP1  21 (   0)   VREPORT       ^V
	;  +--------------- VV2LHP2  13 (   0)   VREPORT       ^V
	;  +--------------- VV2VNIA  10 (   0)   VREPORT       ^V,^VV,^V2
	;  +--------------- VV2VNIB   7 (   0)   VREPORT       ^VV
	;  +--------------- VV2VNIC   3 (   0)   VREPORT       ^V,^VV
	;  +--------------- VV2NR     4 (   0)   VREPORT       ^VV
	;  +--------------- VV2READ   8 (   0)   VREPORT       
	;  +--------------- VV2PAT1   7 (   0)   VREPORT       
	;  +--------------- VV2PAT2  11 (   0)   VREPORT       
	;  +--------------- VV2PAT3  15 (   0)   VREPORT       
	;  +--------------- VV2NO     8 (   0)   VREPORT       ^V,^VV
	;  +--------------- VV2SS1    6 (   0)   VREPORT       ^VV
	;  +--------------- VV2SS2    5 (   0)   VREPORT       ^V,^VV
	;  |
	;  +--------------- STATIS^VREPORT                     ^VREPORT
	;
	;
	;
	;
	;
	;
	;
	;
