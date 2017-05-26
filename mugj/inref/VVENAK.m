VVENAK	;NAKED INDICATOR UNDEFINED;TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
NAKED	W !,"III-1  P.I-12 I-3.2.2.2  Global Variale Name"
	W !,"Prior to the first executed occurrence of a nonnaked form of"
	W !,"gvn, the value of the naked indicator is undefined. It is erroneous for the"
	W !,"first executed occurrence of gvn to be a naked reference.  A nonnaked "
	W !,"reference without subscripts leaves the naked indicator undefined."
	Q
	;
1	W !,"III-1  P.I-12 I-3.2.2.2  Global Variale Name"
	W !,"       Prior to the first executed occurrence of a nonnaked form of"
	W !,"       gvn, the value of the naked indicator is undefined. It is erroneous for the"
	W !,"       first executed occurrence of gvn to be a naked reference.  A nonnaked "
	W !,"       reference without subscripts leaves the naked indicator undefined."
	W !!,"III-1.1  S ^VVE(2)=2,^VVE=0 S B=^(2)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVENAK^1^III-1.1"
	S ^VVE(2)=2,^VVE=0 S B=^(2)
	W !!,"** Failure in producing ERROR for III-1.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVENAK^1^III-1.1^defect"
	Q
	;
2	W !,"III-1  P.I-12 I-3.2.2.2  Global Variale Name"
	W !,"       Prior to the first executed occurrence of a nonnaked form of"
	W !,"       gvn, the value of the naked indicator is undefined. It is erroneous for the"
	W !,"       first executed occurrence of gvn to be a naked reference.  A nonnaked "
	W !,"       reference without subscripts leaves the naked indicator undefined."
	W !!,"III-1.2  S ^VVE(2)=2 S A=$D(^VVE),B=$D(^(2))   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVENAK^2^III-1.2"
	S ^VVE(2)=2 S A=$D(^VVE),B=$D(^(2))
	W !!,"** Failure in producing ERROR for III-1.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVENAK^2^III-1.2^defect"
	Q
	;
3	W !,"III-1  P.I-12 I-3.2.2.2  Global Variale Name"
	W !,"       Prior to the first executed occurrence of a nonnaked form of"
	W !,"       gvn, the value of the naked indicator is undefined. It is erroneous for the"
	W !,"       first executed occurrence of gvn to be a naked reference.  A nonnaked "
	W !,"       reference without subscripts leaves the naked indicator undefined."
	W !!,"III-1.3  S ^VVE(2,2)=22,^VVE=0 S A=^(2,2)   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVENAK^3^III-1.3"
	S ^VVE(2,2)=22,^VVE=0 S A=^(2,2)
	W !!,"** Failure in producing ERROR for III-1.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVENAK^3^III-1.3^defect"
	Q
	;
4	W !,"III-1  P.I-12 I-3.2.2.2  Global Variale Name"
	W !,"       Prior to the first executed occurrence of a nonnaked form of"
	W !,"       gvn, the value of the naked indicator is undefined. It is erroneous for the"
	W !,"       first executed occurrence of gvn to be a naked reference.  A nonnaked "
	W !,"       reference without subscripts leaves the naked indicator undefined."
	W !!,"III-1.4  S ^VVE(2,2)=22,^VVE=0 W $O(^(2,2))   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVENAK^1^III-1.1"
	S ^VVE(2,2)=22,^VVE=0 W $O(^(2,2))
	W !!,"** Failure in producing ERROR for III-1.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVENAK^4^III-1.4^defect"
	Q
	;
