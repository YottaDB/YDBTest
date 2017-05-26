VVELIMS	;STRING LENGTH;TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
	W !,"III-19  P.III-4 III-3.2  Results (1)"
	W !,"Any results, whether intermediate or final, which does not satisfy"
	W !,"the constraints on character strings (Section 2.7) is erroneous."
	Q
	;
1	W !,"III-19  P.III-4 III-3.2  Results (1)"
	W !,"        Any results, whether intermediate or final, which does not satisfy"
	W !,"        the constraints on character strings (Section 2.7) is erroneous."
	W !!,"III-19.1  S A="""" F I=1:1:256 S A=A_""a""   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMS^1^III-19.1" K
	S A="" F I=1:1:256 S A=A_"a"
	W !!,"** Failure in producing ERROR for III-19.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMS^1^III-19.1^defect"
	Q
	;
2	W !,"III-19  P.III-4 III-3.2  Results (1)"
	W !,"        Any results, whether intermediate or final, which does not satisfy"
	W !,"        the constraints on character strings (Section 2.7) is erroneous."
	W !!,"III-19.2  S C=A_B  ;$L(A_B)=300   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMS^2^III-19.2" K
	S A="" F I=1:1:150 S A=A_"a"
	S B="" F I=1:1:150 S B=B_"b"
	S C=A_B
	W !!,"** Failure in producing ERROR for III-19.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMS^2^III-19.2^defect"
	Q
	;
3	W !,"III-19  P.III-4 III-3.2  Results (1)"
	W !,"        Any results, whether intermediate or final, which does not satisfy"
	W !,"        the constraints on character strings (Section 2.7) is erroneous."
	W !!,"III-19.3  W (A_B)=(AA_BB)   ;$L(A_B)=510   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMS^3^III-19.3" K
	S A="" F I=1:1:255 S A=A_"a"
	S B="" F I=1:1:255 S B=B_"b"
	S AA=A,BB=B
	W (A_B)=(AA_BB)
	W !!,"** Failure in producing ERROR for III-19.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMS^3^III-19.3^defect"
	Q
	;
4	W !,"III-19  P.III-4 III-3.2  Results (1)"
	W !,"        Any results, whether intermediate or final, which does not satisfy"
	W !,"        the constraints on character strings (Section 2.7) is erroneous."
	W !!,"III-19.4  W $L(^VVE(1)_^VVE(2))   ;$L(^VVE(1)_^VVE(2))=510   (visual)"
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMS^4^III-19.4" K
	S ^VVE(1)="" F I=1:1:255 S ^VVE(1)=^VVE(1)_"a"
	S ^VVE(2)="" F I=1:1:255 S ^VVE(2)=^VVE(2)_"b"
	W $L(^VVE(1)_^VVE(2))
	W !!,"** Failure in producing ERROR for III-19.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVELIMS^4^III-19.4^defect"
	Q
	;
