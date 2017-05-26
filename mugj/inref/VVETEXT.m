VVETEXT	;$TEXT;TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
TEXT	W !,"III-4  P.I-22 I-3.2.8  $TEXT(lineref), $TEXT(+intexpr)"
	W !,"An error will occur if the value of intexpr is less than 0."
	Q
	;
1	W !,"III-4  P.I-22 I-3.2.8  $TEXT(lineref), $TEXT(+intexpr)"
	W !,"       An error will occur if the value of intexpr is less than 0."
	W !!,"III-4.1  $TEXT(+-1)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVETEXT^1^III-4.1"
	W $TEXT(+-1)
	W !!,"** Failure in producing ERROR for III-4.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVETEXT^1^III-4.1^defect"
	Q
	;
2	W !,"III-4  P.I-22 I-3.2.8  $TEXT(lineref), $TEXT(+intexpr)"
	W !,"       An error will occur if the value of intexpr is less than 0."
	W !!,"III-4.2  S A=$T(+-999999999)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVETEXT^2^III-4.2"
	S A=$T(+-999999999)
	W !!,"** Failure in producing ERROR for III-4.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVETEXT^2^III-4.2^defect"
	Q
	;
3	W !,"III-4  P.I-22 I-3.2.8  $TEXT(lineref), $TEXT(+intexpr)"
	W !,"       An error will occur if the value of intexpr is less than 0."
	W !!,"III-4.3  $T(TEXT+2-3)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVETEXT^3^III-4.3"
	W $T(TEXT+2-3)
	W !!,"** Failure in producing ERROR for III-4.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVETEXT^3^III-4.3^defect"
	Q
	;
4	W !,"III-4  P.I-22 I-3.2.8  $TEXT(lineref), $TEXT(+intexpr)"
	W !,"       An error will occur if the value of intexpr is less than 0."
	W !!,"III-4.4  S A=""TEXT"",B=-300 W $T(@A+B)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVETEXT^4^III-4.4"
	S A="TEXT",B=-300 W $T(@A+B)
	W !!,"** Failure in producing ERROR for III-4.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVETEXT^4^III-4.4^defect"
	Q
	;
