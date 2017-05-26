VVELINB	;LINE REFERENCES (3);TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
LINE	W !,"III-10  P.I-32 I-3.5.7  Line References (3)"
	W !,"In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"  b.  A spelling of label which does not occur in a defining occurrence"
	W !,"      in the given routine."
	Q
	;
1	W !,"III-10  P.I-32 I-3.5.7  Line References (3)"
	W !,"        In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"        b.  A spelling of label which does not occur in a defining occurrence"
	W !,"            in the given routine."
	W !!,"III-10.1  D %00000   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINB^1^III-10.1"
	D %00000
	W !!,"** Failure in producing ERROR for III-10.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINB^1^III-10.1^defect"
	Q
	;
2	W !,"III-10  P.I-32 I-3.5.7  Line References (3)"
	W !,"        In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"        b.  A spelling of label which does not occur in a defining occurrence"
	W !,"            in the given routine."
	W !!,"III-10.2  G QWERTY   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINB^2^III-10.2"
	G QWERTY
	W !!,"** Failure in producing ERROR for III-10.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINB^2^III-10.2^defect"
	Q
	;
3	W !,"III-10  P.I-32 I-3.5.7  Line References (3)"
	W !,"        In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"        b.  A spelling of label which does not occur in a defining occurrence"
	W !,"            in the given routine."
	W !!,"III-10.3  S A=""LABEL"" D @A   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINB^3^III-10.3"
	S A="LABEL" D @A
	W !!,"** Failure in producing ERROR for III-10.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINB^3^III-10.3^defect"
	Q
	;
4	W !,"III-10  P.I-32 I-3.5.7  Line References (3)"
	W !,"        In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"        b.  A spelling of label which does not occur in a defining occurrence"
	W !,"            in the given routine."
	W !!,"III-10.4  S B(2)=12346 G @B(2)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINB^4^III-10.4"
	S B(2)=12346 G @B(2)
	W !!,"** Failure in producing ERROR for III-10.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINB^4^III-10.4^defect"
	Q
	;
