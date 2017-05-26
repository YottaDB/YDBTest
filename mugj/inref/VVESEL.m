VVESEL	;$SELECT;TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
SELECT	W !,"III-3  P.I-22 I-3.2.8  $SELECT(L |tvexpr:expr|)"
	W !,"An error will occur if all tvexprs are false."
	Q
	;
1	W !,"III-3  P.I-22 I-3.2.8  $SELECT(L |tvexpr:expr|)"
	W !,"       An error will occur if all tvexprs are false."
	W !!,"III-3.1  $SELECT(0:""** FAIL $SELECT 1"")   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVESEL^1^III-3.1"
	W $SELECT(0:"** FAIL $SELECT 1")
	W !!,"** Failure in producing ERROR for III-3.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVESEL^1^III-3.1^defect"
	Q
	;
2	W !,"III-3  P.I-22 I-3.2.8  $SELECT(L |tvexpr:expr|)"
	W !,"       An error will occur if all tvexprs are false."
	W !!,"III-3.2  $S(0:""** FAIL $SELECT 2"",'1:""** FAIL $SELECT 3"")   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVESEL^2^III-3.2"
	W $S(0:"** FAIL $SELECT 2",'1:"** FAIL $SELECT 3")
	W !!,"** Failure in producing ERROR for III-3.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVESEL^2^III-3.2^defect"
	Q
	;
3	W !,"III-3  P.I-22 I-3.2.8  $SELECT(L |tvexpr:expr|)"
	W !,"       An error will occur if all tvexprs are false."
	W !!,"III-3.3  $L($S(0:""** FAIL $SELECT 4"",""00""""11DEFG"":""** FAIL $SELECT 5""))   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVESEL^3^III-3.3"
	W $L($S(0:"** FAIL $SELECT 4","00""11DEFG":"** FAIL $SELECT 5"))
	W !!,"** Failure in producing ERROR for III-3.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVESEL^3^III-3.3^defect"
	Q
	;
4	W !,"III-3  P.I-22 I-3.2.8  $SELECT(L |tvexpr:expr|)"
	W !,"       An error will occur if all tvexprs are false."
	W !!,"III-3.4  $S(A+A:""** FAIL $SELECT 6"",A:""** FAIL $SELECT 7"")   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVESEL^4^III-3.4"
	S A=0 W $S(A+A:"** FAIL $SELECT 6",A:"** FAIL $SELECT 7")
	W !!,"** Failure in producing ERROR for III-3.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVESEL^4^III-3.4^defect"
	Q
	;
