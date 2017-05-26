VVELINXN	;LINE REFERENCES (4);TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
	G LINE
	W !,"** FAIL Line reference-2" Q  ;LR-2
	W !,"** FAIL Line reference-1" Q  ;LR-1
LR	W !,"** FAIL Line reference" Q  ;LR+0
	;
LINE	W !,"III-11  P.I-32 I-3.5.7  Line References (4), External routine reference"
	W !,"lineref ::= dlabel [ + intexpr]"
	W !,"A negative value of intexpr is erroneous."
	Q
	;
1	W !,"III-11  P.I-32 I-3.5.7  Line References (4), External routine reference"
	W !,"       lineref ::= dlabel [ + intexpr]"
	W !,"       A negative value of intexpr is erroneous."
	W !!,"III-11.1  DO LR+-1^VVELINN   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXN^1^III-11.1"
	DO LR+-1^VVELINN
	W !!,"** Failure in producing ERROR for III-11.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXN^1^III-11.1^defect"
	Q
	;
2	W !,"III-11  P.I-32 I-3.5.7  Line References (4), External routine reference"
	W !,"       lineref ::= dlabel [ + intexpr]"
	W !,"       A negative value of intexpr is erroneous."
	W !!,"III-11.2  S A=-2 D LR+A^VVELINN   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXN^2^III-11.2"
	S A=-2 D LR+A^VVELINN
	W !!,"** Failure in producing ERROR for III-11.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXN^2^III-11.2^defect"
	Q
	;
3	W !,"III-11  P.I-32 I-3.5.7  Line References (4), External routine reference"
	W !,"       lineref ::= dlabel [ + intexpr]"
	W !,"       A negative value of intexpr is erroneous."
	W !!,"III-11.3  GOTO LR+-1^VVELINN   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXN^3^III-11.3"
	GOTO LR+-1^VVELINN
	W !!,"** Failure in producing ERROR for III-11.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXN^3^III-11.3^defect"
	Q
	;
4	W !,"III-11  P.I-32 I-3.5.7  Line References (4), External routine reference"
	W !,"       lineref ::= dlabel [ + intexpr]"
	W !,"       A negative value of intexpr is erroneous."
	W !!,"III-11.4  S A=-2,B=""LR"" G @B+A^VVELINN   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXN^4^III-11.4"
	S A=-2,B="LR" G @B+A^VVELINN
	W !!,"** Failure in producing ERROR for III-11.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXN^4^III-11.4^defect"
	Q
	;
