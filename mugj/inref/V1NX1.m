V1NX1	;$NEXT FUNCTION -1-;YS-TS,V1NX,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1NX1 : TEST OF $NEXT FUNCTION -1-",!
	W !,"V1NX DEFINES 6 NODES OF AN ARRAY, THEN FINDS THE NODES BY $NEXTING"
	W !,"THROUGH THE ARRAY (VALUE STORED AT A GIVEN NODE IS THE"
	W !,"SUBSCRIPTS OF THAT NODE).  THEN VNX REPEATS THE PROCESS ON A GLOBAL.",!
	;
669	W !,"I-669  glvn is not defined"
	S ITEM="I-669  ",VCOMP="" K ^V1,V1
	S VCOMP=VCOMP_$NEXT(V1(-1))_$N(V1(1))_$N(V1(10))_$N(V1(1,-1))_$N(V1(10,10,10))_" "
	S VCOMP=VCOMP_$NEXT(^V1(-1))_$N(^V1(1))_$N(^V1(10))_$N(^V1(1,-1))_$N(^V1(10,10,10))
	S VCORR="-1-1-1-1-1 -1-1-1-1-1" D EXAMINER
	;
670	W !,"I-670  glvn has no neighboring node"
	S ITEM="I-670  ",VCOMP=""
	K V S V=1 S VCOMP=VCOMP_$N(V(-1))_$N(V(1))_" "
	K V S V(1)=1,VCOMP=VCOMP_$N(V(-1))_$N(V(1))_" "
	K V S V(20,2)=202,VCOMP=VCOMP_$N(V(-1))_$N(V(20))_$N(V(20,-1))_$N(V(20,2))_" "
	K ^V1 S ^V1=1 S VCOMP=VCOMP_$N(^V1(-1))_$N(^V1(1))_" "
	K ^V1 S ^V1(1)=1,VCOMP=VCOMP_$N(^V1(-1))_$N(^V1(1))_" "
	K ^V1 S ^V1(20,2)=202,VCOMP=VCOMP_$N(^V1(-1))_$N(^V1(20))_$N(^V1(20,-1))_$N(^V1(20,2))
	S VCORR="-1-1 1-1 20-12-1 -1-1 1-1 20-12-1" D EXAMINER
	;
671	W !,"I-671  the last subscript of glvn is -1"
	S ITEM="I-671  ",VCOMP="" K ^V1,V1
	S V1(1)=1,V1(1000)=1000,V1(2,2)=22,V1(3,3,3)=333
	S ^V1(1)=1,^V1(1000)=1000,^V1(2,2)=22,^V1(3,3,3)=333
	S VCOMP=VCOMP_$N(V1(-1))_$N(V1(1))_$N(V1(3))_$N(V1(1000))_$N(V1(2))
	S VCOMP=VCOMP_$N(V1(2,1))_$N(V1(2,2))_$N(V1(3,3,0))_$N(V1(3,3,3))_$N(V1(1000,1))_" "
	S VCOMP=VCOMP_$N(^V1(-1))_$N(^V1(1))_$N(^V1(3))_$N(^V1(1000))_$N(^V1(2))
	S VCOMP=VCOMP_$N(^V1(2,1))_$N(^V1(2,2))_$N(^V1(3,3,0))_$N(^V1(3,3,3))_$N(^V1(1000,1))
	S VCORR="121000-132-13-1-1 121000-132-13-1-1" D EXAMINER
	;
672	W !,"I-672  glvn as naked reference"
	S ITEM="I-672  ",VCOMP="" K ^V1
	S ^V1(1)=1,^V1(200)=200,^(30,30)=3030,^(3,3)=33
	S VCOMP=VCOMP_$N(^V1(-1))_" "_$N(^(3))_" "_$N(^(30))_" "_$N(^(30,3))_" "
	S VCOMP=VCOMP_$N(^(0))_" "_$N(^(3,-1))_" "_$N(^(3,3))
	S VCORR="1 30 200 30 3 3 -1" D EXAMINER
	;
673	W !,"I-673  expected returned value is zero"
	S ITEM="I-673  ",VCOMP=""
	K A S A(0)=0,A(0,0)="00",A(0,0,0)="000",A(0,0,0,0)="0000"
	S VCOMP=VCOMP_$N(A(-1))_"^"_A(0)_" "_$N(A(0,-1))_"^"_A(0,0)_" "
	S VCOMP=VCOMP_$N(A(0,0,-1))_"^"_A(0,0,0)_" "_$N(A(0,0,0,-1))_"^"_A(0,0,0,0)_" "
	K ^V1 S ^V1(0)=0,^(0,0)="00",^(0,0)="000",^(0,0)="0000"
	S VCOMP=VCOMP_$N(^V1(-1))_"^"_^V1(0)_" "_$N(^V1(0,-1))_"^"_^V1(0,0)_" "
	S VCOMP=VCOMP_$N(^V1(0,0,-1))_"^"_^V1(0,0,0)_" "_$N(^V1(0,0,0,-1))_"^"_^V1(0,0,0,0)
	S VCORR="0^0 0^00 0^000 0^0000 0^0 0^00 0^000 0^0000" D EXAMINER
	;
END	W !!,"END OF V1NX1",!
	S ROUTINE="V1NX1",TESTS=5,AUTO=5,VISUAL=0 D ^VREPORT
	K  K ^V1 Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
