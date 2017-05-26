VVELINXA	;LINE REFERENCES (5);TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
LINE	W !,"III-12  P.I-32 I-3.5.7  Line References (5), External routine reference"
	W !,"In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"  a.  A value of intexpr so large as not to denote a line within the"
	W !,"      bounds of the given routine."
	Q
	;
1	W !,"III-12  P.I-32 I-3.5.7  Line References (5), External routine reference"
	W !,"       In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"       a.  A value of intexpr so large as not to denote a line within the"
	W !,"           bounds of the given routine."
	W !!,"III-12.1  D LINE+999^VVELINA   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXA^1^III-12.1"
	D LINE+999^VVELINA
	W !!,"** Failure in producing ERROR for III-12.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXA^1^III-12.1^defect"
	Q
	;
2	W !,"III-12  P.I-32 I-3.5.7  Line References (5), External routine reference"
	W !,"       In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"       a.  A value of intexpr so large as not to denote a line within the"
	W !,"           bounds of the given routine."
	W !!,"III-12.2  G 2+999999999^VVELINA   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXA^2^III-12.2"
	G 2+999999999^VVELINA
	W !!,"** Failure in producing ERROR for III-12.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXA^2^III-12.2^defect"
	Q
	;
3	W !,"III-12  P.I-32 I-3.5.7  Line References (5), External routine reference"
%00000	W !,"       In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"       a.  A value of intexpr so large as not to denote a line within the"
	W !,"           bounds of the given routine."
	W !!,"III-12.3  S A=""%00000"" D @A+99999.9999^VVELINA   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXA^3^III-12.3"
	S A="%00000" D @A+99999.9999^VVELINA
	W !!,"** Failure in producing ERROR for III-12.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXA^3^III-12.3^defect"
	Q
	;
4	W !,"III-12  P.I-32 I-3.5.7  Line References (5), External routine reference"
	W !,"       In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"       a.  A value of intexpr so large as not to denote a line within the"
	W !,"           bounds of the given routine."
	W !!,"III-12.4  S B(2,1)=""4"",A=8760 G @B(2,1)+A^VVELINA   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXA^4^III-12.4"
	S B(2,1)="4",A=8760 G @B(2,1)+A^VVELINA
	W !!,"** Failure in producing ERROR for III-12.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINXA^4^III-12.4^defect"
	Q
	;
