VVEFORC	;FOR COMMAND (2);TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
FOR	W !,"III-15  P.I-36 I-3.6.5  FOR command (2)"
	W !,"c. If the forparameter is of the form numexpr1:numexpr2:numexpr3"
	W !,"   and numexpr2 is negative."
	W !,"   6. Execute the scope once; an undefined value for lvn is erroneous."
	Q
	;
1	W !,"III-15  P.I-36 I-3.6.5  FOR command (2)"
	W !,"        c. If the forparameter is of the form numexpr1:numexpr2:numexpr3"
	W !,"           and numexpr2 is negative."
	W !,"           6. Execute the scope once; an undefined value for lvn is erroneous."
	W !!,"III-15.1  FOR I=10:-1:1 S A=I K:A=3 I W A   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORC^1^III-15.1"
	W !,"109876543",!
	FOR I=10:-1:1 S A=I K:A=3 I W A
	W !!,"** Failure in producing ERROR for III-15.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORC^1^III-15.1^defect"
	Q
	;
2	W !,"III-15  P.I-36 I-3.6.5  FOR command (2)"
	W !,"        c. If the forparameter is of the form numexpr1:numexpr2:numexpr3"
	W !,"           and numexpr2 is negative."
	W !,"           6. Execute the scope once; an undefined value for lvn is erroneous."
	W !!,"III-15.2  F I=10:-2:2 D KILL    ;(KILL W I IF I=6 K I)   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORC^2^III-15.2"
	W !,"1086",!
	F I=10:-2:2 D KILL
	W !!,"** Failure in producing ERROR for III-15.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORC^2^III-15.2^defect"
	Q
	;
3	W !,"III-15  P.I-36 I-3.6.5  FOR command (2)"
	W !,"        c. If the forparameter is of the form numexpr1:numexpr2:numexpr3"
	W !,"           and numexpr2 is negative."
	W !,"           6. Execute the scope once; an undefined value for lvn is erroneous."
	W !!,"III-15.3  S A=""I"",C=0 F I=10:-1:1 S C=C+1 W C IF C=5 K @A   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORC^3^III-15.3"
	W !,"12345",!
	S A="I",C=0 F I=10:-1:1 S C=C+1 W C IF C=5 K @A
	W !!,"** Failure in producing ERROR for III-15.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORC^3^III-15.3^defect"
	Q
	;
4	W !,"III-15  P.I-36 I-3.6.5  FOR command (2)"
	W !,"        c. If the forparameter is of the form numexpr1:numexpr2:numexpr3"
	W !,"           and numexpr2 is negative."
	W !,"           6. Execute the scope once; an undefined value for lvn is erroneous."
	W !!,"III-15.4  S A=1,B=-1,C=10 F I=A:B:C K B,C S A=A+1,I=9 W A IF A=5 KILL I   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORC^4^III-15.4"
	W !,"2345",!
	S A=1,B=-1,C=10 F I=A:B:C K B,C S A=A+1,I=9 W A IF A=5 KILL I
	W !!,"** Failure in producing ERROR for III-15.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEFORC^4^III-15.4^defect"
	Q
	;
	Q
KILL	W I IF I=6 K I
	Q
