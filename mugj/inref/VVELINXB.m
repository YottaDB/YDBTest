VVELINXB	;LINE REFERENCES (6);TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
LINE	W !,"III-13  P.I-32 I-3.5.7  Line References (6), External routine reference"
	W !,"In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"  b.  A spelling of label which does not occur in a defining occurrence"
	W !,"      in the given routine."
	Q
	;
1	W !,"III-13  P.I-32 I-3.5.7  Line References (6), External routine reference"
	W !,"        In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"        b.  A spelling of label which does not occur in a defining occurrence"
	W !,"            in the given routine."
	W !!,"III-13.1  D %00000^VVELINB   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXB^1^III-13.1"
	D %00000^VVELINB
	W !!,"** Failure in producing ERROR for III-13.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXB^1^III-13.1^defect"
	Q
	;
2	W !,"III-13  P.I-32 I-3.5.7  Line References (6), External routine reference"
	W !,"        In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"        b.  A spelling of label which does not occur in a defining occurrence"
	W !,"            in the given routine."
	W !!,"III-13.2  G QWERTY^VVELINB   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXB^2^III-13.2"
	G QWERTY^VVELINB
	W !!,"** Failure in producing ERROR for III-13.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXB^2^III-13.2^defect"
	Q
	;
3	W !,"III-13  P.I-32 I-3.5.7  Line References (6), External routine reference"
	W !,"        In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"        b.  A spelling of label which does not occur in a defining occurrence"
	W !,"            in the given routine."
	W !!,"III-13.3  S A=""LABEL"" D @A^VVELINB   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXB^3^III-13.3"
	S A="LABEL" D @A^VVELINB
	W !!,"** Failure in producing ERROR for III-13.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXB^3^III-13.3^defect"
	Q
	;
4	W !,"III-13  P.I-32 I-3.5.7  Line References (6), External routine reference"
	W !,"        In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"        b.  A spelling of label which does not occur in a defining occurrence"
	W !,"            in the given routine."
	W !!,"III-13.4  S B(2)=12346 G @B(2)^VVELINB   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXB^4^III-13.4"
	S B(2)=12346 G @B(2)^VVELINB
	W !!,"** Failure in producing ERROR for III-13.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXB^4^III-13.4^defect"
	Q
	;
