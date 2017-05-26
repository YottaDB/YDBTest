VVEUNDF	;UNDEFINED VALUE;TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
UNDEF	W !,"III-5  P.I-24 I-3.3  Expressions  expr"
	W !,"Any attempt to evaluate an expratom containing an lvn, gvn, or svn with an"
	W !,"undefined value is erroneous."
	Q
	;
1	W !,"III-5  P.I-24 I-3.3  Expressions  expr"
	W !,"       Any attempt to evaluate an expratom containing an lvn, gvn, or svn with an"
	W !,"       undefined value is erroneous."
	W !!,"III-5.1  KILL A S B=B(A)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEUNDF^1^III-5.1"
	KILL A S B=B(A)
	W !!,"** Failure in producing ERROR for III-5.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEUNDF^1^III-5.1^defect"
	Q
	;
2	W !,"III-5  P.I-24 I-3.3  Expressions  expr"
	W !,"       Any attempt to evaluate an expratom containing an lvn, gvn, or svn with an"
	W !,"       undefined value is erroneous."
	W !!,"III-5.2  KILL ^VVE S A=A(^VVE)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEUNDF^2^III-5.2"
	KILL ^VVE S A=A(^VVE)
	W !!,"** Failure in producing ERROR for III-5.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEUNDF^2^III-5.2^defect"
	Q
	;
3	W !,"III-5  P.I-24 I-3.3  Expressions  expr"
	W !,"       Any attempt to evaluate an expratom containing an lvn, gvn, or svn with an"
	W !,"       undefined value is erroneous."
	W !!,"III-5.3  S A=2,B(2)=0 K A S B(A)=3   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEUNDF^3^III-5.3"
	S A=2,B(2)=0 K A S B(A)=3
	W !!,"** Failure in producing ERROR for III-5.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEUNDF^3^III-5.3^defect"
	Q
	;
4	W !,"III-5  P.I-24 I-3.3  Expressions  expr"
	W !,"       Any attempt to evaluate an expratom containing an lvn, gvn, or svn with an"
	W !,"       undefined value is erroneous."
	W !!,"III-5.4  K ^VVE W 12_^VVE(2)_34   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEUNDF^4^III-5.4"
	K ^VVE W 12_^VVE(2)_34
	W !!,"** Failure in producing ERROR for III-5.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEUNDF^4^III-5.4^defect"
	Q
	;
