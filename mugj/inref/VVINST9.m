VVINST9	;Instruction V.7.1 -9-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                  Validation Instruction - Structure Table
	;
	;Structure Tables of ANSI/MDC X11.1-1984  Validation Suite Version 7.1
	;
	;
	;Part I   Total Items ------------  847
	;         Total Tests (visual) --- 1946 ( 68)
	;         Total Routines----------  191 and VREPORT
	;
	;
	;main    sub      routine   tests       support           using
	;driver  driver               (visual)   routine(s)        global
	;
	; VV1                                                     ^VREPORT
	;  |
	;  +--------------- V1WR      4 (   4)   VREPORT
	;  +--------------- V1CMT     5 (   5)   VREPORT
	;  +--------------- V1LL1    13 (   0)   VREPORT
	;  +--------------- V1LL2    21 (   0)   VREPORT
	;  +--------------- V1PRGD    9 (   0)   VREPORT
	;  |                                     V1PRGD1
	;  |                                     V1PRGD2
	;  |                                     V1PRGD3
	;  |
	;  +--------------- V1RN      5 (   0)   VREPORT
	;  |                         V,V0,V000006,V01,V012
	;  |                         V12345,V4444,V7777777
	;  |                         VA,VAB,VABC,VABCD,VABCDE
	;  |                         VABCDEF,VABCDEFG,VABCDEFH
	;  |                         %, %2345678,%BCDEFGH,%1A
	;  |
	;  +--------------- V1PRSET   4 (   4)   VREPORT
	;  +--------------- V1PRIE    9 (   0)   VREPORT
	;  +--------------- V1PRFOR   4 (   0)   VREPORT
	;  +-- V1NUM
	;  |     +--------- V1NUM1   28 (   0)   VREPORT
	;  |     +--------- V1NUM2   21 (   0)   VREPORT
	;  |     +--------- V1NUM3   23 (   0)   VREPORT
	;  |     +--------- V1NUM4   31 (   0)   VREPORT
	;  |
	;  +-- V1FC
	;  |     +--------- V1FC1     9 (   9)   VREPORT
	;  |     +--------- V1FC2     6 (   6)   VREPORT
	;  |
	;  +-- V1UO
	;
	;
