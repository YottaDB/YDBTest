VVINST11	;Instruction V.7.1 -11-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                   Validation Instruction - Structure Table
	;
	;
	;  |     +--------- V1FNL    29 (   0)   VREPORT
	;  |     +--------- V1FNP1   17 (   0)   VREPORT
	;  |     +--------- V1FNP2   21 (   0)   VREPORT
	;  |
	;  +-- V1AC
	;  |     +--------- V1AC1     9 (   0)   VREPORT
	;  |     +--------- V1AC2    19 (   0)   VREPORT
	;  |
	;  +--------------- V1LVN    16 (   0)   VREPORT
	;  +--------------- V1GVN    17 (   0)   VREPORT       ^%,^%ABCDEF,^%1234
	;  |                                                   ^%A1,^%ABC456GH,^%1X2Y3Z
	;  |                                                   ^V,^V1,^V1A,^V100,^V1AB
	;  |                                                   ^V1Z1Y2X,^V1ABCDE
	;  |                                                   ^V1ABCDEF,^V100000A
	;  |
	;  +--------------- V1DLA     8 (   0)   VREPORT       ^ITEM,^PASS,^FAIL,^VCOMP
	;  +-- V1DLB
	;  |     +--------- V1DLB1    6 (   0)   VREPORT       ^ITEM,^PASS,^FAIL
	;  |     |
	;  |     +--------- V1DLB2    5 (   0)   VREPORT       ^ITEM,^PASS,^FAIL
	;  |
	;  +--------------- V1DLC     5 (   0)   VREPORT       ^ITEM,^PASS,^FAIL,^VCOMP
	;  |
	;  +--------------- V1DGA     9 (   0)   VREPORT       ^PASS,^FAIL,^V1A,^V1B
	;  |                                                   ^V1C,^V1D,^V1E,^V1F,^V1G
	;  |                                                   ^GLOBAL00,^Z0000000
	;  +-- V1DGB
	;  |     +--------- V1DGB1    6 (   0)   VREPORT       ^V1
	;  |     |
	;  |     +--------- V1DGB2    5 (   0)   VREPORT       ^V1,^V1A,^V1ZZZ,^V10,^V11
	;  |
	;  +-- V1NR
	;  |     +--------- V1NR1     9 (   0)   VREPORT       ^V1A,^V1B,^V1C,^V1CC
	;  |     |
	;  |     +--------- V1NR2     8 (   0)   VREPORT       ^V1A,^V1B,^V1C
	;  |
	;  +-- V1NX
	;  |     +--------- V1NX1     5 (   0)   VREPORT       ^V1
	;  |     |
	;  |     +--------- V1NX2     2 (   0)   VREPORT       ^V1
	;  |
	;  +--------------- V1SET     8 (   0)   VREPORT       ^V1,^V1A,^V1B,^V1C
	;  |                                                   ^V1D,^V1E
	;  +-- V1GO
