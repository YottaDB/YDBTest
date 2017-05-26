V1NR1	;NAKED REFERENCE -1-;YS-TS,V1NR,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1NR1: TEST OF NAKED REFERENCES ON GLOBAL VARIABLES -1-",!
648	W !,"I-648  interpretation sequence of SET command"
	S ITEM="I-648  " K ^V1A,^V1B
	S ^V1A(1)=100,^(2)=^(1)+100,^(2,3)=^(1)+130,^(4)=^(3)+10
	S VCOMP=^V1A(1)_" "_^V1A(2)_" "_^V1A(2,3)_" "_^V1A(2,4)_" "
	S ^V1B(1)=10000,^(1,2)=^(1)+2000,^(2,3)=^(2)+300,^(3,4)=^(3)+40
	S VCOMP=VCOMP_^V1B(1)_" "_^V1B(1,2)_" "_^V1B(1,2,3)_" "_^V1B(1,2,3,4)
	S VCORR="100 200 230 240 10000 12000 12300 12340" D EXAMINER
	;
649	W !,"I-649  interpretation sequence of subscripted variable"
	S ITEM="I-649.1  local variable's subscript" K ^V1A,^V1B
	S ^V1A(1)=100,^V1B(1,200)=12000,^V1A(2)=200
	S ^(3)=^V1A(2)+100 S X(^(1))=^V1B(1,^(2))
	S VCOMP=^V1A(3)_" "_X(100),VCORR="300 12000" D EXAMINER
	;
	S ITEM="I-649.2  glvn is naked reference" K ^V1C
	S ^V1C(1)=2,^(1,2)=3,^(2,3)=4 S VCOMP=^V1C(1,2,3)_" "_^V1C(1,2)_" "_^V1C(1)
	S VCORR="4 3 2" D EXAMINER
	;
	S ITEM="I-649.3  subscripts are naked reference" K ^V1CC
	K ^V1C S ^V1C(1,2)=3,^V1C(1,2,3)=4,^V1C(1)=2
	S ^V1CC(1)=^(^(1),^(1,2)) S VCOMP=^V1CC(1),VCORR="4" D EXAMINER
	;
	S ITEM="I-649.4  nesting naked reference" K ^V1C,^V1CC
	S ^V1C(1)=2,^(1,2)=3,^(2,3)=4,^(4,1)=10 S ^(3,4)=^(2,^(1,^V1C(1)))+^(4,1)
	S VCOMP=^V1C(1,2,4,3,4)_" "
	S ^V1CC(1)=4,^V1C(1)=2 S ^V1CC(2)="TWO",^V1C(2)="ONE" S ^(^(1))=^V1CC(1)
	S VCOMP=VCOMP_^V1CC(2) S VCORR="14 4" D EXAMINER
	;
	S ITEM="I-649.5  6 level subscripts"
	K ^V1A S ^V1A(1)=1,^(2,3)=23,^(1,2,3,4,5)=^(3)
	S VCOMP=^V1A(1)_" "_^V1A(2,3)_" "_^V1A(2,1,2,3,4,5)
	S VCORR="1 23 23" D EXAMINER
	;
650	W !,"I-650  effect of global reference in $DATA on naked indicator"
	S ITEM="I-650.1  2 level subscripts",VCOMP=""
	K ^V1A S ^V1A(1,1)=2 S VCOMP=VCOMP_$D(^V1A(1,2)) S ^(3)="B" S VCOMP=VCOMP_^V1A(1,3)
	K ^V1A S ^V1A(1,1)=1 S VCOMP=VCOMP_$D(^(2)) S ^(3)="A" S VCOMP=VCOMP_^V1A(1,3)
	S VCORR="0B0A" D EXAMINER
	;
	S ITEM="I-650.2  a subscript"
	K ^V1A S ^V1A(1,1)=3 S VCOMP=$D(^V1A(0)) S ^(3)="C" S VCOMP=VCOMP_^V1A(3)
	S VCORR="0C" D EXAMINER
	;
	S ITEM="I-650.3  2 globals using"
	K ^V1A,^V1B S ^V1A(1,1)=8,^V1B(1,3)="#"
	S VCOMP=$D(^V1A(1,2)) S ^(3)="I" S VCOMP=VCOMP_^V1B(1,3)_^V1A(1,3)
	S VCORR="0#I" D EXAMINER
	;
END	W !!,"END OF V1NR1",!
	S ROUTINE="V1NR1",TESTS=9,AUTO=9,VISUAL=0 D ^VREPORT
	K ^V1A,^V1B,^V1C,^V1CC K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
