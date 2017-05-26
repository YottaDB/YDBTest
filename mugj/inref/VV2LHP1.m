VV2LHP1	;LEFT-HAND $PIECE -1-;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
	S PASS=0,FAIL=0
	W !!,"VV2LHP1: TEST OF LEFT-HAND $PIECE -1-",!
	W !,"$PIECE(glvn,expr1)",!
96	W !,"II-96  expr1 is string literal"
	S ITEM="II-96  ",X="A^B^C",$P(X,"^")="D",VCOMP=X,VCORR="D^B^C" D EXAMINER
	;
	W !!,"$PIECE(glvn,expr1,intexpr2)",!
97	W !,"II-97  expr1 is string literal"
	S ITEM="II-97  ",VCOMP="A1B1C",$P(VCOMP,"1",3)="DD",VCORR="A1B1DD" D EXAMINER
	;
	W !!,"$PIECE(glvn,expr1,intexpr2,intexpr3) K=max(0,$L(glvn,expr1)-1)",!
98	W !,"II-98  intexpr2>intexpr3"
	S ITEM="II-98  ",VCOMP="A^B^C",$P(VCOMP,"^",2,1)="D",VCORR="A^B^C" D EXAMINER
	;
99	W !,"II-99  intexpr3<1"
	S ITEM="II-99.1  intexpr2=1"
	S VCOMP="A^B^C",$P(VCOMP,"^",1,-1)="D",VCORR="A^B^C" D EXAMINER
	;
	S ITEM="II-99.2  intexpr2<intexpr3",VCOMP="A^B^C",$P(VCOMP,"^",-555555,-3)="D",VCORR="A^B^C" D EXAMINER
	;
	S ITEM="II-99.3  intexpr2>intexpr3",VCOMP="A^B^C",$P(VCOMP,"^",-3,-533333)="D",VCORR="A^B^C" D EXAMINER
	;
100	W !,"II-100  K<intexpr2-1<intexpr3"
	S ITEM="II-100.1  K=0" S VCOMP="A^B^C",$P(VCOMP,"#",3,4)="D" S VCORR="A^B^C##D" D EXAMINER
	;
	S ITEM="II-100.2  K=1" S VCOMP="A^B^C",$P(VCOMP,"B",3,5)="00" S VCORR="A^B^CB00" D EXAMINER
	;
	S ITEM="II-100.3  K=2" S ^V="A^B^C",$P(^V,"^",5,7)="D",VCOMP=^V S VCORR="A^B^C^^D" D EXAMINER
	;
101	W !,"II-101  intexpr2-1<=K<intexpr3"
	S ITEM="II-101.1  K=0" S VCOMP="A^B^C",$P(VCOMP,"##",1,1)="$$" S VCORR="$$" D EXAMINER
	;
	S ITEM="II-101.2  K=1" S X(1)="A^B^C",$P(X(1),"B",2,3)="$$" S VCOMP=X(1),VCORR="A^B$$" D EXAMINER
	;
	S ITEM="II-101.3  K=2" S VCOMP="A^B^C",$P(VCOMP,"^",2,4)="D" S VCORR="A^D" D EXAMINER
	;
102	W !,"II-102  intexpr2-1<intexpr3<=K"
	S ITEM="II-102.1  K=1" S VCOMP="A^B^C",$P(VCOMP,"B",1,1)="%%",VCORR="%%B^C" D EXAMINER
	;
	S ITEM="II-102.2  K=2" S VCOMP="A^B^C",$P(VCOMP,"^",2,2)="D",VCORR="A^D^C" D EXAMINER
	;
	S ITEM="II-102.3  K=5" S ^V("A")="A^^B^^C^^D^^E^^F",$P(^V("A"),"^^",2,4)="1" S VCOMP=^V("A")
	S VCORR="A^^1^^E^^F" D EXAMINER
	;
103	W !,"II-103  $D(glvn)=0 and intexpr3<1"
	S ITEM="II-103  " K X S $P(X,"^",0,-1)="A",VCOMP=$D(X),VCORR="0" D EXAMINER
	;
104	W !,"II-104  $D(glvn)=0 and intexpr2>intexpr3"
	S ITEM="II-104  " K ^V S $P(^V,"^",3,2)=1,VCOMP=$D(^V),VCORR="0" D EXAMINER
	;
105	W !,"II-105  $D(glvn)=0 and intexpr3>intexpr2>1"
	S ITEM="II-105  " K X S $P(X,"^",2,3)=$D(X),VCOMP=X,VCORR="^0" D EXAMINER
	;
106	W !,"II-106  intexpr2<1"
	S ITEM="II-106  ",VCOMP=""
	S X="A/B/C",$P(X,"/",-3,2)="D" S VCOMP=VCOMP_X_" "
	S X="A/B/C",$P(X,"/",-99999,33)="D" S VCOMP=VCOMP_X
	S VCORR="D/C D" D EXAMINER
	;
107	W !,"II-107  glvn is naked reference"
	S ITEM="II-107  ",VCOMP="" K ^V
	S ^V(1,2)="A^B^C",$P(^(2),"^")="D" S VCOMP=VCOMP_^(2)_" "_^V(1,2)_" "
	K ^V S ^V(1)=1,$P(^("A"),"-",3)="1" S VCOMP=VCOMP_^V("A")
	S VCORR="D^B^C D^B^C --1" D EXAMINER
	;
108	W !,"II-108  Interpretation sequence of subscripted left hand $PIECE"
	S ITEM="II-108  ",VCOMP=""
	K ^V S ^V(1)=1,^(1,2)="1^2",^(3)="1^3",$P(^(3,3),$E(^(3),2),$P(^(2),"^",2))=^(3)
	S VCOMP=VCOMP_^(3)_" "_^V(1,3,3) S VCORR="^1^3 ^1^3" D EXAMINER
	;
END	W !!,"END OF VV2LHP1",!
	S ROUTINE="VV2LHP1",TESTS=21,AUTO=21,VISUAL=0 D ^VREPORT
	K  K ^V Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
