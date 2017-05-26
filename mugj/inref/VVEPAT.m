VVEPAT	;PATTERN MATCH;TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
PATTERN	W !,"III-7  P.I-27 I-3.3.3  Pattern match"
	W !,"If repcount has the form of a range, intlit1.intlit2, the first intlit"
	W !,"gives the lower bound, and the second intlit the upper bound."
	W !,"It is erroneous if the upper bound is less than the lower bound."
	Q
	;
1	W !,"III-7  P.I-27 I-3.3.3  Pattern match"
	W !,"       If repcount has the form of a range, intlit1.intlit2, the first intlit"
	W !,"       gives the lower bound, and the second intlit the upper bound."
	W !,"       It is erroneous if the upper bound is less than the lower bound."
	W !!,"III-7.1  123?2.1N   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEPAT^1^III-7.1"
	W 123?2.1N
	W !!,"** Failure in producing ERROR for III-7.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEPAT^1^III-7.1^defect"
	Q
	;
2	W !,"III-7  P.I-27 I-3.3.3  Pattern match"
	W !,"       If repcount has the form of a range, intlit1.intlit2, the first intlit"
	W !,"       gives the lower bound, and the second intlit the upper bound."
	W !,"       It is erroneous if the upper bound is less than the lower bound."
	W !!,"III-7.2  "" ABC ""'?2.0UP   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEPAT^2^III-7.2"
	W " ABC "'?2.0UP
	W !!,"** Failure in producing ERROR for III-7.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEPAT^2^III-7.2^defect"
	Q
	;
3	W !,"III-7  P.I-27 I-3.3.3  Pattern match"
	W !,"       If repcount has the form of a range, intlit1.intlit2, the first intlit"
	W !,"       gives the lower bound, and the second intlit the upper bound."
	W !,"       It is erroneous if the upper bound is less than the lower bound."
	W !!,"III-7.3  ""    ""?999999999.255"" ""   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEPAT^3^III-7.3"
	W "    "?999999999.255" "
	W !!,"** Failure in producing ERROR for III-7.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEPAT^3^III-7.3^defect"
	Q
	;
4	W !,"III-7  P.I-27 I-3.3.3  Pattern match"
	W !,"       If repcount has the form of a range, intlit1.intlit2, the first intlit"
	W !,"       gives the lower bound, and the second intlit the upper bound."
	W !,"       It is erroneous if the upper bound is less than the lower bound."
	W !!,"III-7.4  S A=29,B=A?3.2N   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEPAT^4^III-7.4"
	S A=29,B=A?3.2N
	W !!,"** Failure in producing ERROR for III-7.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEPAT^4^III-7.4^defect"
	Q
	;
