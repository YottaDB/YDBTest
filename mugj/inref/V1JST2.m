V1JST2	; $JUSTIFY, $SELECT, $TEXT -2-;YS-KO-TS,V1JST,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1JST2: TEST OF $JUSTIFY, $SELECT AND $TEXT FUNCTIONS -2-",!
	W !,"$JUSTIFY(numexpr1,intexpr2,intexpr3)",!
572	W !,"I-572  numexpr1 is empty string"
	S ITEM="I-572.1  intexpr3=1" S VCOMP=$J("",8,1),VCORR="     0.0" D EXAMINER
	S ITEM="I-572.2  intexpr3>1" S VCOMP=$J("",8,3),VCORR="   0.000" D EXAMINER
	;
573	W !,"I-573  numexpr1 is positive non-integer numeric"
	S ITEM="I-573  " S VCOMP=$J(1E1/3,"5.3A",.6E-1*100),VCORR="3.333333" D EXAMINER
	;
574	W !,"I-574  numexpr1 is negative non-integer numeric"
	S ITEM="I-574.1  intexpr3=2" S VCOMP=$J(-00123.456000,8,2),VCORR=" -123.46" D EXAMINER
	S ITEM="I-574.2  intexpr3=1" S VCOMP=$J(-00123.456000,8,1),VCORR="  -123.5" D EXAMINER
	S ITEM="I-574.3  intexpr3=0" S VCOMP=$J(-00123.456000,8,0),VCORR="    -123" D EXAMINER
	S ITEM="I-574.4  intexpr3=0 another" S VCOMP=$J(-00123.546000,8,0),VCORR="    -124" D EXAMINER
	;
575	W !,"I-575  numexpr1 is greater than zero and less than one"
	S ITEM="I-575.1  numexpr1>0" S VCOMP=$J(0.0099,5,2),VCORR=" 0.01" D EXAMINER
	S ITEM="I-575.2  numexpr1<0" S VCOMP=$J(-0.0099,7,2),VCORR="  -0.01" D EXAMINER
	;
576	W !,"I-576  numexpr1 is mant exp"
	S ITEM="I-576.1  -0.0099E1" S VCOMP=$J(-0.0099E1,7,2),VCORR="  -0.10" D EXAMINER
	S ITEM="I-576.2  -1.0099E-1" S VCOMP=$J(-1.0099E-1,8,4),VCORR=" -0.1010" D EXAMINER
	S ITEM="I-576.3  000.004567E+7",VCOMP=$J(000.004567E+7,10,1),VCORR="   45670.0" D EXAMINER
	;
577	W !,"I-577  intexpr2<0"
	S ITEM="I-577  ",VCOMP=$J(1.011,-10,2),VCORR="1.01" D EXAMINER
	;
578	W !,"I-578   intexpr2=0"
	S ITEM="I-578  ",VCOMP=$J("5.2",1,0),VCORR="5" D EXAMINER
	;
579	W !,"I-579  intexpr2>0 and intexpr3>0"
	S ITEM="I-579  ",VCOMP=$J(5.2,5,3),VCORR="5.200" D EXAMINER
	;
580	W !,"I-580  intexpr2<0 and intexpr3=0"
	S ITEM="I-580  ",VCOMP=$J(5.2,-2,0),VCORR="5" D EXAMINER
	;
581	W !,"I-581  intexpr2<0 and intexpr3<0"
	W !,"       ( This test I-581 was nullified in 1984 ANSI, MSL )"
	;S ITEM="I-581  ",VCOMP=$J(5.2,-2,-5),VCORR="5" D EXAMINER
	;
582	W !,"I-582  intexpr2>intexpr3"
	S ITEM="I-582  ",VCOMP=$J("5.449",9,2),VCORR="     5.45" D EXAMINER
	;
583	W !,"I-583  intexpr2=intexpr3"
	S ITEM="I-583.1  expr1=""5.449""" S VCOMP=$J("5.449",5,5),VCORR="5.44900" D EXAMINER
	S ITEM="I-583.2  expr1=""9995E-4""" S VCOMP=$J("9995E-4",3,3),VCORR="1.000" D EXAMINER
	;
584	W !,"I-584  intexpr2<intexpr3"
	S ITEM="I-584  ",VCOMP=$J("5.5",1,2),VCORR="5.50" D EXAMINER
	;
585	W !,"I-585  interpretation of intexpr2, intexpr3"
	S ITEM="I-585  " K ^V1A
	S ^V1A(2,2)="-232.896EMPTY",^V1A(2,2,2)=10.9,^V1A(2,2,2,2)=2.8
	S VCOMP=$D(^V1A(2)),VCOMP=VCOMP_$J(^(2,2),1+^(2,2),^(2,2))
	S VCORR="10    -232.90" D EXAMINER
	;
END	W !!,"END OF V1JST2",!
	S ROUTINE="V1JST2",TESTS=21,AUTO=21,VISUAL=0 D ^VREPORT
	K  K ^V1A Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
