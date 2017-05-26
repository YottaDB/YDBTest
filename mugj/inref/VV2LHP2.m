VV2LHP2	;LEFT-HAND $PIECE -2-;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
	S PASS=0,FAIL=0
	W !!,"VV2LHP2: TEST OF LEFT-HAND $PIECE -2-",!
109	W !,"II-109  Naked indicator when intexpr2>intexpr3"
	S ITEM="II-109  ",VCOMP=""
	K ^V S ^V(1,2)="A",$P(^(2,2),"^",2,1)="D" S VCOMP=VCOMP_^(2)_" "
	K ^V S ^V(3,3)="X",^V(3)=0,$P(^(3,3),^(3,3),20,2)="Y" S VCOMP=VCOMP_^(3)
	S VCORR="A X" D EXAMINER
	;
110	W !,"II-110  Naked indicator when intexpr3<1"
	S ITEM="II-110  ",VCOMP=""
	K ^V S ^V(1)=1,$P(^(2,3),"^",1,0)="A" S VCOMP=^(1)_" "_$D(^V(2,3))
	S VCORR="1 0" D EXAMINER
	;
111	W !,"II-111  Lower case letter left hand ""$piece"""
	S ITEM="II-111  ",VCOMP=""
	S X="A^B^C",$piece(X,"^")="D" S VCOMP=VCOMP_X_" "
	S X="A^B^C",$p(X,"^",3)="D" S VCOMP=VCOMP_X_" "
	S X="A^B^C",$piECE(X,"^",2,1)="D" S VCOMP=VCOMP_X
	S VCORR="D^B^C A^B^D A^B^C" D EXAMINER
	;
112	W !,"II-112  Left hand $PIECE with postcondition"
	S ITEM="II-112  ",VCOMP="" K X
	S:$D(X)=0 X="A**B**C",$PIECE(X,"**",2)="D" S VCOMP=VCOMP_X_" "
	S:$D(X)=0 $P(X,"**",2)="E" S VCOMP=VCOMP_X
	S VCORR="A**D**C A**D**C" D EXAMINER
	;
113	W !,"II-113  Indirection of left hand $PIECE"
	S ITEM="II-113  ",VCOMP=""
	S X="A---B---CDEFG---H",Y="---",Z="$P(X,Y,2,3)=123",@Z S VCOMP=VCOMP_X_" "
	S A="C",C="A^B^C^D^E^F",B="D",D="^",$P(@A,@B,3,4)="G" S VCOMP=VCOMP_@A
	S VCORR="A---123---H A^B^G^E^F" D EXAMINER
	;
114	W !,"II-114  expr1 is empty string"
	S ITEM="II-114  ",VCOMP=""
	S A="ABC",$P(A,"")="D",B="ABC",$P(B,"",2)="D"
	S C="ABCD",$P(C,"",2,3)="E",D="ABC",$P(D,"",1,3)="D"
	S VCOMP=A_" "_B_" "_C_" "_D,VCORR="D ABCD ABCDE D" D EXAMINER
	;
115	W !,"II-115  Value of glvn is numeric data"
	S ITEM="II-115  ",VCOMP=""
	S X=002305102,$P(X,0.0,2,2)=15 S VCOMP=VCOMP_X_" "
	S X=1212.425,$P(X,".",2,3)="000" S VCOMP=VCOMP_X_" "
	S X=12.324E2,$P(X,2,3,999)=00 S VCOMP=VCOMP_X
	S VCORR="2301502 1212.000 12320" D EXAMINER
	;
116	W !,"II-116  Control characters are used as delimiters (expr1)"
	S ITEM="II-116  ",VCOMP=""
	S Y=$C(13),VCOMP="A"_Y_"B"_Y_"C",$P(VCOMP,Y,2,2)="D"
	S VCORR="A"_Y_"D"_Y_"C" D EXAMINER
	;
117	W !,"II-117  Value of expr1 contains operators"
	S ITEM="II-117  ",VCOMP=""
	S X=012030405,$P(X,+"A"-"E",3)=6 S VCOMP=VCOMP_X_" "
	S X=21319,$P(X,2=2)=003 S VCOMP=VCOMP_X_" "
	S X="A1B1C",$P(X,"ABC"["C",02,10E2)="" S VCOMP=VCOMP_X
	S VCORR="12030605 31319 A1" D EXAMINER
	;
118	W !,"II-118  intexpr2 and intexpr3 are numlits"
	S ITEM="II-118  "
	S VCOMP="A*B*C",$P(VCOMP,"*",002.30,2.99999)="D" S VCORR="A*D*C" D EXAMINER
	;
119	W !,"II-119  Value of expr1,intexpr2,intexpr3 are functions"
	S ITEM="II-119.1  $C"
	S VCOMP="A*B*C",$P(VCOMP,$C(42))="D" S VCORR="D*B*C" D EXAMINER
	;
	S ITEM="II-119.2  $L"
	S VCOMP="ABCABCABCABCABCABCABC",Y="B",$P(VCOMP,Y,2,$L(VCOMP,Y))="-"
	S VCORR="AB-" D EXAMINER
	;
	S ITEM="II-119.3  $P" S Y="ABC*ABC*ABC*ABC",VCOMP=""
	F I=1:1 S A=$T(TEX+I),X=Y Q:A=""  S $P(X,$P(A,";",2),$P(A,";",3),$P(A,";",4))=$P(A,";",5),VCOMP=VCOMP_X_" "
	S VCORR="DDD*ABC*ABC*ABC ABCDDDABC DDDABC*ABC ABC*ABC*ABC*ABCD " D EXAMINER
	;
END	W !!,"END OF VV2LHP2",!
	S ROUTINE="VV2LHP2",TESTS=13,AUTO=13,VISUAL=0 D ^VREPORT
	K  K ^V Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
TEX	;
	;*;1;1;DDD;DDD*ABC*ABC*ABC
	;ABC;2;4;DDD;ABCDDDABC
	;ABC*A;1;2;DDD;DDDABC*ABC
	;ABC*ABC*ABC*ABC;2;3;D;ABC*ABC*ABC*ABCD
