VVELINA	;LINE REFERENCES (2);TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
LINE	W !,"III-9  P.I-32 I-3.5.7  Line References (2)"
	W !,"In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"  a.  A value of intexpr so large as not to denote a line within the"
	W !,"      bounds of the given routine."
	Q
	;
1	W !,"III-9  P.I-32 I-3.5.7  Line References (2)"
	W !,"       In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"       a.  A value of intexpr so large as not to denote a line within the"
	W !,"           bounds of the given routine."
	W !!,"III-9.1  D LINE+999   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINA^1^III-9.1"
	D LINE+999
	W !!,"** Failure in producing ERROR for III-9.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINA^1^III-9.1^defect"
	Q
	;
2	W !,"III-9  P.I-32 I-3.5.7  Line References (2)"
	W !,"       In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"       a.  A value of intexpr so large as not to denote a line within the"
	W !,"           bounds of the given routine."
	W !!,"III-9.2  G 2+999999999   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINA^2^III-9.2"
	G 2+999999999
	W !!,"** Failure in producing ERROR for III-9.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINA^2^III-9.2^defect"
	Q
	;
3	W !,"III-9  P.I-32 I-3.5.7  Line References (2)"
%00000	W !,"       In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"       a.  A value of intexpr so large as not to denote a line within the"
	W !,"           bounds of the given routine."
	W !!,"III-9.3  S A=""%00000"" D @A+99999.9999   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINA^3^III-9.3"
	S A="%00000" D @A+99999.9999
	W !!,"** Failure in producing ERROR for III-9.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINA^3^III-9.3^defect"
	Q
	;
4	W !,"III-9  P.I-32 I-3.5.7  Line References (2)"
	W !,"       In the context of DO or GOTO, either of the following conditions is erroneous."
	W !,"       a.  A value of intexpr so large as not to denote a line within the"
	W !,"           bounds of the given routine."
	W !!,"III-9.4  S B(2,1)=""4"",A=8760 G @B(2,1)+A   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINA^4^III-9.4"
	S B(2,1)="4",A=8760 G @B(2,1)+A
	W !!,"** Failure in producing ERROR for III-9.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELINA^4^III-9.4^defect"
	Q
	;
