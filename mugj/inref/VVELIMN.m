VVELIMN	;INTEGER RANGE;TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
	W !,"III-20  P.III-4 III-3.2  Results (2)"
	W !,"Furthermore, integer results are erroneous if they do not also"
	W !,"satisfy the constraints on integers (Section 2.6)."
	Q
	;
1	W !,"III-20  P.III-4 III-3.2  Results (2)"
	W !,"        Furthermore, integer results are erroneous if they do not also"
	W !,"        satisfy the constraints on integers (Section 2.6)."
	W !!,"III-20.1  W 9999999999   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMN^1^III-20.1" K
	W 9999999999
	W !!,"** Failure in producing ERROR for III-20.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMN^1^III-20.1^defect"
	Q
	;
2	W !,"III-20  P.III-4 III-3.2  Results (2)"
	W !,"        Furthermore, integer results are erroneous if they do not also"
	W !,"        satisfy the constraints on integers (Section 2.6)."
	W !!,"III-20.2  S A=12345678901E+2   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMN^2^III-20.2" K
	S A=12345678901E+2
	W !!,"** Failure in producing ERROR for III-20.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMN^2^III-20.2^defect"
	Q
	;
3	W !,"III-20  P.III-4 III-3.2  Results (2)"
	W !,"        Furthermore, integer results are erroneous if they do not also"
	W !,"        satisfy the constraints on integers (Section 2.6)."
	W !!,"III-20.3  S A=123456789012+123456789012   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMN^3^III-20.3" K
	S A=123456789012+123456789012
	W !!,"** Failure in producing ERROR for III-20.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMN^3^III-20.3^defect"
	Q
	;
4	W !,"The following test concludes the all the 72 tests."
	W !,"After running III-20.4, type in ""DO ^VVESTAT"" for obtaing"
	W !,"the Results Statistics Table.",!!
	;
	W !,"III-20  P.III-4 III-3.2  Results (2)"
	W !,"        Furthermore, integer results are erroneous if they do not also"
	W !,"        satisfy the constraints on integers (Section 2.6)."
	W !!,"III-20.4  S A=$F(9876543210987654,0)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMN^4^III-20.4"
	S A=$F(9876543210987654,0)
	W !!,"** Failure in producing ERROR for III-20.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMN^4^III-20.4^defect"
	Q
	;
