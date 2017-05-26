VVINST12	;Instruction V.7.1 -12-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                   Validation Instruction - Structure Table
	;
	;
	;  |     +--------- V1GO1    30 (   0)   VREPORT
	;  |     +--------- V1GO2    10 (   0)   VREPORT       ^V1A
	;  |
	;  +--------------- V1OV     20 (   0)   VREPORT       ^V1A,^V1OV1
	;  |                                     V1OV1
	;  |
	;  +-- V1DO
	;  |     +--------- V1DO1    10 (   0)   VREPORT
	;  |     +--------- V1DO2    21 (   0)   VREPORT
	;  |     +--------- V1DO3    12 (   0)   VREPORT       ^V1A,^V1DO3
	;  |
	;  +--------------- V1CALL   17 (   0)   VREPORT       ^V1A
	;  |                                     V1CALL1
	;  |
	;  +-- V1IE
	;  |     +--------- V1IE1    12 (   0)   VREPORT
	;  |     +--------- V1IE2    13 (   0)   VREPORT
	;  |
	;  +-- V1PC
	;  |     +--------- V1PCA    11 (   0)   VREPORT       ^V,^V1PC1
	;  |     |                               V1PC1
	;  |     |
	;  |     +--------- V1PCB     9 (   0)   VREPORT       ^V,^V1,^V1PC1
	;  |                                     V1PC1
	;  |
	;  +-- V1FORA
	;  |     +--------- V1FORA1  17 (   0)   VREPORT
	;  |     +--------- V1FORA2  11 (   0)   VREPORT
	;  |
	;  +--------------- V1FORB   15 (   0)   VREPORT
	;  +-- V1FORC
	;  |     +--------- V1FORC1   9 (   0)   VREPORT       ^V1A,^V1B
	;  |     +--------- V1FORC2   8 (   0)   VREPORT
	;  |
	;  +-- V1IDNM
	;  |     +--------- V1IDNM1   8 (   0)   VREPORT       ^V1A,^V1B
	;  |     |
	;  |     +--------- V1IDNM2  12 (   0)   VREPORT       ^V1A,^V1B
	;  |     |
	;  |     +--------- V1IDNM3   9 (   0)   VREPORT       ^V1A
	;  |
	;  +-- V1IDGO
	;  |     +--------- V1IDGOA   6 (   0)   VREPORT       ^V1A,^V1IDGO1
	;  |     |                               V1IDGO1
