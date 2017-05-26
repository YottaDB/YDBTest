VVERAND	;$RANDOM;TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
RANDOM	W !,"III-2  P.I-22 I-3.2.8  $RANDOM(intexpr)"
	W !,"If the value of intexpr is less than 1, an error will occur."
	Q
	;
1	W !,"III-2  P.I-22 I-3.2.8  $RANDOM(intexpr)"
	W !,"       If the value of intexpr is less than 1, an error will occur."
	W !!,"III-2.1  $RANDOM(0)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVERAND^1^III-2.1"
	W $RANDOM(0)
	W !!,"** Failure in producing ERROR for III-2.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVERAND^1^III-2.1^defect"
	Q
	;
2	W !,"III-2  P.I-22 I-3.2.8  $RANDOM(intexpr)"
	W !,"       If the value of intexpr is less than 1, an error will occur."
	W !!,"III-2.2  $R(00.999999999)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVERAND^2^III-2.2"
	W $R(00.999999999)
	W !!,"** Failure in producing ERROR for III-2.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVERAND^2^III-2.2^defect"
	Q
	;
3	W !,"III-2  P.I-22 I-3.2.8  $RANDOM(intexpr)"
	W !,"       If the value of intexpr is less than 1, an error will occur."
	W !!,"III-2.3  S A=$R(-1)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVERAND^3^III-2.3"
	S A=$R(-1)
	W !!,"** Failure in producing ERROR for III-2.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVERAND^3^III-2.3^defect"
	Q
	;
4	W !,"III-2  P.I-22 I-3.2.8  $RANDOM(intexpr)"
	W !,"       If the value of intexpr is less than 1, an error will occur."
	W !!,"III-2.4  S A=-99999999.9,B=$R(A)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVERAND^4^III-2.4"
	S A=-99999999.9,B=$R(A)
	W !!,"** Failure in producing ERROR for III-2.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVERAND^4^III-2.4^defect"
	Q
	;
