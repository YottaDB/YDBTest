VVELINN	;LINE REFERENCES (1);TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
	G LINE
	W !,"** FAIL Line reference-2" Q  ;LR-2
	W !,"** FAIL Line reference-1" Q  ;LR-1
LR	W !,"** FAIL Line reference" Q  ;LR+0
	;
LINE	W !,"III-8  P.I-32 I-3.5.7  Line References (1)"
	W !,"lineref ::= dlabel [ + intexpr]"
	W !,"A negative value of intexpr is erroneous."
	Q
	;
1	W !,"III-8  P.I-32 I-3.5.7  Line References (1)"
	W !,"       lineref ::= dlabel [ + intexpr]"
	W !,"       A negative value of intexpr is erroneous."
	W !!,"III-8.1  DO LR+-1   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINN^1^III-8.1"
	DO LR+-1
	W !!,"** Failure in producing ERROR for III-8.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINN^1^III-8.1^defect"
	Q
	;
2	W !,"III-8  P.I-32 I-3.5.7  Line References (1)"
	W !,"       lineref ::= dlabel [ + intexpr]"
	W !,"       A negative value of intexpr is erroneous."
	W !!,"III-8.2  S A=-2 D LR+A   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINN^2^III-8.2"
	S A=-2 D LR+A
	W !!,"** Failure in producing ERROR for III-8.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINN^2^III-8.2^defect"
	Q
	;
3	W !,"III-8  P.I-32 I-3.5.7  Line References (1)"
	W !,"       lineref ::= dlabel [ + intexpr]"
	W !,"       A negative value of intexpr is erroneous."
	W !!,"III-8.3  GOTO LR+-1   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINN^3^III-8.3"
	GOTO LR+-1
	W !!,"** Failure in producing ERROR for III-8.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINN^3^III-8.3^defect"
	Q
	;
4	W !,"III-8  P.I-32 I-3.5.7  Line References (1)"
	W !,"       lineref ::= dlabel [ + intexpr]"
	W !,"       A negative value of intexpr is erroneous."
	W !!,"III-8.4  S A=-2,B=""LR"" G @B+A   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINN^4^III-8.4"
	S A=-2,B="LR" G @B+A
	W !!,"** Failure in producing ERROR for III-8.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINN^4^III-8.4^defect"
	Q
	;
