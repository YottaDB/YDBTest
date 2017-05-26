VVEFORD	;VVE FOR COMMAND (3);TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
FOR	W !,"III-16  P.I-36 I-3.6.5  FOR command (3)"
	W !,"d. If the forparameter is of the form numexpr1:numexpr2."
	W !,"   4. Execute the scope once; an undefined value for lvn is erroneous."
	Q
	;
1	W !,"III-16  P.I-36 I-3.6.5  FOR command (3)"
	W !,"        d. If the forparameter is of the form numexpr1:numexpr2."
	W !,"           4. Execute the scope once; an undefined value for lvn is erroneous."
	W !!,"III-16.1  FOR I=1:1 S A=I W I K:I=3 I   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORD^1^III-16.1"
	W !,"123",!
	FOR I=1:1 S A=I W I K:I=3 I
	W !!,"** Failure in producing ERROR for III-16.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORD^1^III-16.1^defect"
	Q
	;
2	W !,"III-16  P.I-36 I-3.6.5  FOR command (3)"
	W !,"        d. If the forparameter is of the form numexpr1:numexpr2."
	W !,"           4. Execute the scope once; an undefined value for lvn is erroneous."
	W !!,"III-16.2  FOR I=10:-1 W I K:I=3 I   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORD^2^III-16.2"
	W !,"109876543",!
	FOR I=10:-1 W I K:I=3 I
	W !!,"** Failure in producing ERROR for III-16.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORD^2^III-16.2^defect"
	Q
	;
3	W !,"III-16  P.I-36 I-3.6.5  FOR command (3)"
	W !,"        d. If the forparameter is of the form numexpr1:numexpr2."
	W !,"           4. Execute the scope once; an undefined value for lvn is erroneous."
	W !!,"III-16.3  F I=1:1 D KILL   ;(KILL W I IF I=6 K I)   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORD^3^III-16.3"
	W !,"123456",!
	F I=1:1 D KILL
	W !!,"** Failure in producing ERROR for III-16.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORD^3^III-16.3^defect"
	Q
	;
4	W !,"III-16  P.I-36 I-3.6.5  FOR command (3)"
	W !,"        d. If the forparameter is of the form numexpr1:numexpr2."
	W !,"           4. Execute the scope once; an undefined value for lvn is erroneous."
	W !!,"III-16.4  S A=1 F I=0:0 S A=A+1 W A I A=6 K I   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORD^4^III-16.4"
	W !,"123456",!
	S A=0 F I=0:0 S A=A+1 W A I A=6 K I
	W !!,"** Failure in producing ERROR for III-16.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORD^4^III-16.4^defect"
	Q
	;
	Q
KILL	W I IF I=6 K I
	Q
