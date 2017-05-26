VVEFORB	;FOR COMMAND (1);TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
FOR	W !,"III-14  P.I-36 I-3.6.5  FOR command (1)"
	W !,"b. If the forparameter is of the form numexpr1:numexpr2:numexpr3"
	W !,"   and numexpr2 is nonnegative."
	W !,"   6. Execute the scope once; an undefined value for lvn is erroneous."
	Q
	;
1	W !,"III-14  P.I-36 I-3.6.5  FOR command (1)"
	W !,"        b. If the forparameter is of the form numexpr1:numexpr2:numexpr3"
	W !,"           and numexpr2 is nonnegative."
	W !,"           6. Execute the scope once; an undefined value for lvn is erroneous."
	W !!,"III-14.1  FOR I=1:1:10 S A=I W I K:A=3 I   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORB^1^III-14.1"
	W !,"123",!
	FOR I=1:1:10 S A=I W I K:A=3 I
	W !!,"** Failure in producing ERROR for III-14.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORB^1^III-14.1^defect"
	Q
	;
2	W !,"III-14  P.I-36 I-3.6.5  FOR command (1)"
	W !,"        b. If the forparameter is of the form numexpr1:numexpr2:numexpr3"
	W !,"           and numexpr2 is nonnegative."
	W !,"           6. Execute the scope once; an undefined value for lvn is erroneous."
	W !!,"III-14.2  S A=1 F I=1:0:10 S A=A+1 W A I A=7 K I   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORB^2^III-14.2"
	W !,"234567",!
	S A=1 F I=1:0:10 S A=A+1 W A I A=7 K I
	W !!,"** Failure in producing ERROR for III-14.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORB^2^III-14.2^defect"
	Q
	;
3	W !,"III-14  P.I-36 I-3.6.5  FOR command (1)"
	W !,"        b. If the forparameter is of the form numexpr1:numexpr2:numexpr3"
	W !,"           and numexpr2 is nonnegative."
	W !,"           6. Execute the scope once; an undefined value for lvn is erroneous."
	W !!,"III-14.3  F I=2:2:20 D KILL   ;(KILL W I IF I=10 K I)   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORB^3^III-14.3"
	W !,"246810",!
	F I=2:2:20 D KILL
	W !!,"** Failure in producing ERROR for III-14.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORB^3^III-14.3^defect"
	Q
	;
4	W !,"III-14  P.I-36 I-3.6.5  FOR command (1)"
	W !,"        b. If the forparameter is of the form numexpr1:numexpr2:numexpr3"
	W !,"           and numexpr2 is nonnegative."
	W !,"           6. Execute the scope once; an undefined value for lvn is erroneous."
	W !!,"III-14.4  X ""F A(2)=1:1:10 W A(2) IF A(2)=5 KILL A""   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORB^4^III-14.4"
	W !,"12345",!
	X "F A(2)=1:1:10 W A(2) IF A(2)=5 KILL A"
	W !!,"** Failure in producing ERROR for III-14.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORB^4^III-14.4^defect"
	Q
	;
	Q
KILL	W I IF I=10 K I
	Q
