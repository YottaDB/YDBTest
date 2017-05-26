VVEDOC8	;VVEDOC V.7.1 -8-;TS,VVEDOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-III
	;
	;P.III-4  integer range
	;     (VVELIMN)
	;
	;     III-20  P.III-4 III-3.2  Results (2)
	;             Furthermore, integer results are erroneous if they do not also
	;             satisfy the constraints on integers (Section 2.6).
	;       III-20.1  W 9999999999
	;       III-20.2  S A=12345678901E+2
	;       III-20.3  S A=123456789012+123456789012
	;       III-20.4  S A=$F(9876543210987654,0)
	;
	;
	;END
