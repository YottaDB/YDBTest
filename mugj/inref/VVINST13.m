VVINST13	;Instruction V.7.1 -13-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                   Validation Instruction - Structure Table
	;
	;
	;  |     |
	;  |     +--------- V1IDGOB   8 (   0)   VREPORT       ^V1A,^V1IDGO1
	;  |                                     V1IDGO1
	;  |
	;  +-- V1IDDO
	;  |     +--------- V1IDDOA   7 (   0)   VREPORT       ^V1A,^V1IDDO1
	;  |     |                               V1IDDO1
	;  |     |
	;  |     +--------- V1IDDOB   7 (   0)   VREPORT       ^V1A,^V1IDDO1
	;  |                                     V1IDDO1
	;  |
	;  +-- V1IDARG
	;  |     +--------- V1IDARG1  9 (   0)   VREPORT       ^V1A
	;  |     |
	;  |     +--------- V1IDARG2  9 (   0)   VREPORT       ^V1A,^V1B
	;  |     |
	;  |     +--------- V1IDARG3  9 (   0)   VREPORT       ^V1A,^V1B,^V1C,^V1D
	;  |     +--------- V1IDARG4  9 (   9)   VREPORT
	;  |     +--------- V1IDARG5  8 (   0)   VREPORT       ^V1
	;  |
	;  +-- V1XECA
	;  |     +--------- V1XECA1   9 (   0)   VREPORT
	;  |     |
	;  |     +--------- V1XECA2  13 (   0)   VREPORT
	;  |                                     V1XECAE
	;  |
	;  +--------------- V1XECB    7 (   0)   VREPORT
	;  +--------------- V1SEQ     7 (   0)   VREPORT
	;  |                                     V1SEQ1
	;  |
	;  +-- V1PAT
	;  |     +--------- V1PAT1   14 (   0)   VREPORT
	;  |     +--------- V1PAT2   10 (   0)   VREPORT       ^V1
	;  |
	;  +--------------- V1NST1    6 (   0)   VREPORT
	;  |                                     V1NSTE
	;  |
	;  +--------------- V1NST2    3 (   0)   VREPORT       ^V1ID
	;  |                                     V1NSTE
	;  |
	;  +--------------- V1NST3    3 (   0)   VREPORT
	;  |                                     V1NSTE
	;  |
	;  +-- V1JST
