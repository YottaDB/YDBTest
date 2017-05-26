VVEDIV	;DIVISION BY ZERO;TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
DIVISION	W !,"III-6  P.I-24 I-3.3.1  / produces the algebraic quotient"
	W !,"Division by zero is erroneous."
	Q
	;
1	W !,"III-6  P.I-24 I-3.3.1  / produces the algebraic quotient"
	W !,"       Division by zero is erroneous."
	W !!,"III-6.1  1/0   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEDIV^1^III-6.1"
	W 1/0
	W !!,"** Failure in producing ERROR for III-6.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEDIV^1^III-6.1^defect"
	Q
	;
2	W !,"III-6  P.I-24 I-3.3.1  / produces the algebraic quotient"
	W !,"       Division by zero is erroneous."
	W !!,"III-6.2  0/0   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEDIV^2^III-6.2"
	W 0/0
	W !!,"** Failure in producing ERROR for III-6.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEDIV^2^III-6.2^defect"
	Q
	;
3	W !,"III-6  P.I-24 I-3.3.1  / produces the algebraic quotient"
	W !,"       Division by zero is erroneous."
	W !!,"III-6.3  4/$L("""")   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEDIV^3^III-6.3"
	W 4/$L("")
	W !!,"** Failure in producing ERROR for III-6.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEDIV^3^III-6.3^defect"
	Q
	;
4	W !,"III-6  P.I-24 I-3.3.1  / produces the algebraic quotient"
	W !,"       Division by zero is erroneous."
	W !!,"III-6.4  S A=2345979/0000E2+3   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEDIV^4^III-6.4"
	S A=2345979/0000E2+3
	W !!,"** Failure in producing ERROR for III-6.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEDIV^4^III-6.4^defect"
	Q
	;
