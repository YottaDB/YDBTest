VVEKILL	;KILL COMMAND;TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
KILL	W !,"III-17  P.I-39 I-3.6.10  KILL command"
	W !,"Killing the variable M sets $D(M) = 0 and causes the value of M to be"
	W !,"undefined.  Any attempt to obtain the value of M while it is undefined is"
	W !,"erroneous."
	Q
	;
1	W !,"III-17  P.I-39 I-3.6.10  KILL command"
	W !,"        Killing the variable M sets $D(M) = 0 and causes the value of M to be"
	W !,"        undefined.  Any attempt to obtain the value of M while it is undefined is"
	W !,"        erroneous."
	W !!,"III-17.1  S A=10 KILL A S B=A   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEKILL^1^III-17.1"
	S A=10 KILL A S B=A
	W !!,"** Failure in producing ERROR for III-17.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEKILL^1^III-17.1^defect"
	Q
	;
2	W !,"III-17  P.I-39 I-3.6.10  KILL command"
	W !,"        Killing the variable M sets $D(M) = 0 and causes the value of M to be"
	W !,"        undefined.  Any attempt to obtain the value of M while it is undefined is"
	W !,"        erroneous."
	W !!,"III-17.2  S ^VVE=0 KILL ^VVE S A=^VVE   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEKILL^2^III-17.2"
	S ^VVE=0 KILL ^VVE S A=^VVE
	W !!,"** Failure in producing ERROR for III-17.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEKILL^2^III-17.2^defect"
	Q
	;
3	W !,"III-17  P.I-39 I-3.6.10  KILL command"
	W !,"        Killing the variable M sets $D(M) = 0 and causes the value of M to be"
	W !,"        undefined.  Any attempt to obtain the value of M while it is undefined is"
	W !,"        erroneous."
	W !!,"III-17.3  S A(2)=8 K A W A(2)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEKILL^3^III-17.3"
	S A(2)=8 K A W A(2)
	W !!,"** Failure in producing ERROR for III-17.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEKILL^3^III-17.3^defect"
	Q
	;
4	W !,"III-17  P.I-39 I-3.6.10  KILL command"
	W !,"        Killing the variable M sets $D(M) = 0 and causes the value of M to be"
	W !,"        undefined.  Any attempt to obtain the value of M while it is undefined is"
	W !,"        erroneous."
	W !!,"III-17.4  S ^VVE(1,2,20)=123 K ^VVE W ^VVE(1,2,20)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEKILL^4^III-17.4"
	S ^VVE(1,2,20)=123 K ^VVE W ^VVE(1,2,20)
	W !!,"** Failure in producing ERROR for III-17.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEKILL^4^III-17.4^defect"
	Q
	;
