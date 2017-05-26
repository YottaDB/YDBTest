V1JST1	;$JUSTIFY, $SELECT, $TEXT -1-;YS-KO-TS,V1JST,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1JST1: TEST OF $JUSTIFY, $SELECT AND $TEXT FUNCTIONS -1-"
JUSTIFY	W !!,"$JUSTIFY(expr1,intexpr2)",!
555	W !,"I-555  expr1 is string literal"
	S ITEM="I-555  " S VCOMP=$JUSTIFY("5.47",10) S VCORR="      5.47" D EXAMINER
	;
556	W !,"I-556  expr1 is empty string"
	S ITEM="I-556  " S VCOMP=$J("",5),VCORR="     " D EXAMINER
	;
557	W !,"I-557  expr1 is positive integer"
	S ITEM="I-557.1  0001234.0000" S VCOMP=$J(0001234.0000,7),VCORR="   1234" D EXAMINER
	S ITEM="I-557.2  000123400.00E1",VCOMP=$J(000123400.00E1,10),VCORR="   1234000" D EXAMINER
	;
558	W !,"I-558  expr1 is negative integer"
	S ITEM="I-558.1  -00098" S VCOMP=$J(-00098,5),VCORR="  -98" D EXAMINER
	S ITEM="I-558.2  -0009800.00" S VCOMP=$J(-0009800.00,8),VCORR="   -9800" D EXAMINER
	;
559	W !,"I-559  expr1 is positive non-integer numeric"
	S ITEM="I-559  0987654.E-003" S VCOMP=$J(0987654.E-003,12),VCORR="     987.654" D EXAMINER
	;
560	W !,"I-560  expr1 is negative non-integer numeric"
	S ITEM="I-560  -9876.54E-003",VCOMP=$J(-9876.54E-003,12),VCORR="    -9.87654" D EXAMINER
	;
561	W !,"I-561  expr1 is greater than zero and less than one"
	S ITEM="I-561  98.7654E-003" S VCOMP=$J(98.7654E-003,12),VCORR="    .0987654" D EXAMINER
	;
562	W !,"I-562  expr1 contains binary operator"
	S ITEM="I-562.1  ""12AHD""*""12""",VCOMP=$J("12AHD"*"12",10),VCORR="       144" D EXAMINER
	S ITEM="I-562.2  ""-""_""0012""" S VCOMP=$J("-"_"0012",8),VCORR="   -0012" D EXAMINER
	;
563	W !,"I-563  expr1 contains unary operator"
	S ITEM="I-563  " S VCOMP=$J(-"0012",8),VCORR="     -12" D EXAMINER
	;
564	W !,"I-564  expr1 contains function"
	S ITEM="I-564.1  $LENGTH" S VCOMP=$J($L("ABCDE"),4),VCORR="   5" D EXAMINER
	S ITEM="I-564.2  $JUSTIFY" S VCOMP=$J($J("ABCDE",6),8),VCORR="   ABCDE" D EXAMINER
	;
565	W !,"I-565  expr1 contains gvn"
	S ITEM="I-565  " S ^V1A="ABCD",VCOMP=$J(^V1A,6),VCORR="  ABCD" D EXAMINER
	;
566	W !,"I-566  intexpr2>0"
	S ITEM="I-566  " S VCORR="" F I=1:1:255 S VCORR=VCORR_" "
	S VCOMP=$J(" ",255) D EXAMINER
	;
567	W !,"I-567  intexpr2=0"
	S ITEM="I-567  ",VCOMP=$J("5.99",0),VCORR="5.99" D EXAMINER
	;
568	W !,"I-568  intexpr2<0"
	S ITEM="I-568  ",VCOMP=$J("5.490",-1),VCORR="5.490" D EXAMINER
	;
569	W !,"I-569  intexpr2<$L(expr1)"
	S ITEM="I-569.1  intexpr2=1" S VCOMP=$J("05.490",1),VCORR="05.490" D EXAMINER
	S ITEM="I-569.2  intexpr2=($L(expr1)+1)" S VCOMP=$J("05.490",5),VCORR="05.490" D EXAMINER
	;
570	W !,"I-570  intexpr2=$L(expr1)"
	S ITEM="I-570  " S VCOMP=$J("05.490",6),VCORR="05.490" D EXAMINER
	;
571	W !,"I-571  intexpr2>$L(expr1)"
	S ITEM="I-571  " S VCOMP=$J(05.490,8.9),VCORR="    5.49" D EXAMINER
	;
END	W !!,"END OF V1JST1",!
	S ROUTINE="V1JST1",TESTS=22,AUTO=22,VISUAL=0 D ^VREPORT
	K  K ^V1A Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
