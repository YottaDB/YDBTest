VVINST14	;Instruction V.7.1 -14-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                   Validation Instruction - Structure Table
	;
	;
	;  |     +--------- V1JST1   22 (   0)   VREPORT       ^V1A
	;  |     |
	;  |     +--------- V1JST2   21 (   0)   VREPORT       ^V1A
	;  |     |
	;  |     +--------- V1JST3   17 (   0)   VREPORT       ^V1A,^V1B,^V1C,^V1D
	;  |
	;  +--------------- V1SVH     2 (   1)   VREPORT
	;  +--------------- V1SVS     5 (   0)   VREPORT       ^ITEM,^PASS,^FAIL,^VCOMP
	;  +-- V1MAX
	;  |     +--------- V1MAX1    7 (   1)   VREPORT       ^V1
	;  |     |
	;  |     +--------- V1MAX2    4 (   0)   VREPORT       ^V1
	;  |
	;  +--------------- V1BR      7 (   0)   VREPORT
	;  |                                     V1BR1
	;  |
	;  +-- V1READA
	;  |     +--------- V1READA1  8 (   0)   VREPORT
	;  |     +--------- V1READA2  5 (   0)   VREPORT
	;  |
	;  +-- V1READB
	;  |     +--------- V1READB1  8 (   0)   VREPORT
	;  |     +--------- V1READB2  9 (   0)   VREPORT
	;  |
	;  +--------------- V1HANG   16 (  16)   VREPORT
	;  +--------------- V1PO     10 (   0)   VREPORT
	;  +--------------- V1RANDA   4 (   4)   VREPORT
	;  +--------------- V1RANDB   7 (   7)   VREPORT
	;  +--------------- V1IO     20 (   0)   VREPORT
	;  |                                     V1IO1
	;  |                                     V1IO2
	;  |
	;  +-- V1MJA
	;  |     +--------- V1MJA1   10 (   0)   VREPORT       ^V1A,^V1B,^V1F
	;  |     |                               V1MJB
	;  |     |            (V1MJB is in another partition)
	;  |     +--------- V1MJA2    9 (   0)   VREPORT       ^V1A,^V1B,^V1F
	;  |                                     V1MJB
	;  |                  (V1MJB is in another partition)
	;  +--------------- STATIS^VREPORT                     ^VREPORT
	;
	;
	;
	;
