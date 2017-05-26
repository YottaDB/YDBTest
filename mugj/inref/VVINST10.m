VVINST10	;Instruction V.7.1 -10-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                   Validation Instruction - Structure Table
	;
	;
	;  |     +--------- V1UO1A   19 (   0)   VREPORT
	;  |     +--------- V1UO1B   26 (   0)   VREPORT
	;  |     +--------- V1UO2A   19 (   0)   VREPORT
	;  |     +--------- V1UO2B   26 (   0)   VREPORT
	;  |     +--------- V1UO3A   19 (   0)   VREPORT
	;  |     +--------- V1UO3B   26 (   0)   VREPORT
	;  |     +--------- V1UO4A   18 (   0)   VREPORT
	;  |     +--------- V1UO4B   30 (   0)   VREPORT
	;  |     +--------- V1UO5A   36 (   0)   VREPORT
	;  |     +--------- V1UO5B   22 (   0)   VREPORT
	;  |
	;  +-- V1BOA
	;  |     +--------- V1BOA1   32 (   0)   VREPORT
	;  |     +--------- V1BOA2   27 (   0)   VREPORT
	;  |     +--------- V1BOA3   25 (   0)   VREPORT
	;  |     +--------- V1BOA4   27 (   0)   VREPORT
	;  |     +--------- V1BOA5   26 (   0)   VREPORT
	;  |     +--------- V1BOA6   47 (   0)   VREPORT
	;  |
	;  +-- V1BOB
	;  |     +--------- V1BOB1   39 (   0)   VREPORT
	;  |     +--------- V1BOB2   41 (   0)   VREPORT
	;  |     +--------- V1BOB3   37 (   0)   VREPORT
	;  |     +--------- V1BOB4   32 (   0)   VREPORT
	;  |     +--------- V1BOB5A  32 (   0)   VREPORT
	;  |     +--------- V1BOB5B  18 (   0)   VREPORT
	;  |     +--------- V1BOB6A  26 (   0)   VREPORT
	;  |     +--------- V1BOB6B  16 (   0)   VREPORT
	;  |     +--------- V1BOB7   30 (   0)   VREPORT
	;  |     +--------- V1BOB8   29 (   0)   VREPORT
	;  |     +--------- V1BOB9   31 (   0)   VREPORT
	;  |     +--------- V1BOB10  34 (   0)   VREPORT
	;  |
	;  +-- V1BOC
	;  |     +--------- V1BOC1   26 (   0)   VREPORT
	;  |     +--------- V1BOC2   26 (   0)   VREPORT
	;  |     +--------- V1BOC3   15 (   0)   VREPORT
	;  |
	;  +-- V1FN
	;  |     +--------- V1FNE1   28 (   0)   VREPORT
	;  |     +--------- V1FNE2   21 (   0)   VREPORT
	;  |     +--------- V1FNF1   18 (   0)   VREPORT
	;  |     +--------- V1FNF2   18 (   0)   VREPORT
	;  |     +--------- V1FNF3   19 (   0)   VREPORT
