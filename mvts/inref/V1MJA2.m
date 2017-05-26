V1MJA2 ;IW-KO-TS,V1MJA,MVTS V9.10;15/6/96;LOCK, OPEN, CLOSE, $JOB, $IO and $TEST  -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 S ^NEXT="END^VV1" W:$Y>50 #
 K ^V1A,^V1B,^V1F
 W !!,"196---V1MJA2: Multi-job  -2-"
OPEN W !!,"Tests of OPEN and $TEST",! S ^V1F=""
 D SETPARA^V1MJA
 ;
639 W !,"I-639  OPEN the same device from two partitions"
 S ^ABSN="12142",^ITEM="I-639  OPEN the same device from two partitions",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP="" I 1
 OPEN:1 ^V1A("OPEN") K ^V1F
 S POS="639" D HANG S VCOMP=VCOMP_^V1F C ^V1A("CLOSE")
 S ^VCOMP=VCOMP,^VCORR="0/1" D ^VEXAMINE
 ;
640 W !,"I-640  OPEN with timeout and its effect on $TEST"
 S ^ABSN="12143",^ITEM="I-640  OPEN with timeout and its effect on $TEST",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=""
 O ^V1B("OPEN TIMEOUT") S VCOMP=VCOMP_$T_" " K ^V1F
 S POS="640" D HANG S VCOMP=VCOMP_^V1F C ^V1B("CLOSE")
 S ^VCOMP=VCOMP,^VCORR="1 1" D ^VEXAMINE
 ;
641 W !,"I-641  Argument list of OPEN command"
 S ^ABSN="12144",^ITEM="I-641  Argument list of OPEN command",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=""
 O ^V1A("OPEN TIMEOUT"),^V1B("OPEN TIMEOUT") S VCOMP=VCOMP_$T_" " K ^V1F
 S POS="641" D HANG S VCOMP=VCOMP_^V1F CLOSE ^V1A("CLOSE"),^V1B("CLOSE")
 S ^VCOMP=VCOMP,^VCORR="1 0/0" D ^VEXAMINE
 ;
642 W !,"I-642  Effect of CLOSE on another partition"
 S ^ABSN="12145",^ITEM="I-642  Effect of CLOSE on another partition",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=""
 O ^V1A("OPEN TIMEOUT") S VCOMP=VCOMP_$T_" " K ^V1F
 S POS="642-1" D HANG S VCOMP=VCOMP_^V1F
 C ^V1A("CLOSE") K ^V1F
 S POS="642-2" D HANG S VCOMP=VCOMP_^V1F
 O ^V1A("OPEN TIMEOUT") S VCOMP=VCOMP_$T C ^V1A("CLOSE")
 S ^VCOMP=VCOMP,^VCORR="1 0/1/1" D ^VEXAMINE
 ;
643 W !,"I-643  Postconditional of CLOSE command"
 S ^ABSN="12146",^ITEM="I-643  Postconditional of CLOSE command",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=""
 O ^V1B("OPEN TIMEOUT") S VCOMP=VCOMP_$T_" " C:10="QWE" ^V1B("CLOSE")
 O ^V1B("OPEN TIMEOUT") CLOSE:"ABD"="ABD" ^V1B("CLOSE") S VCOMP=VCOMP_$T_" "
 S ^VCOMP=VCOMP,^VCORR="1 1 " D ^VEXAMINE
 ;
644 W !,"I-644  CLOSE the device which is not OPENed"
 S ^ABSN="12147",^ITEM="I-644  CLOSE the device which is not OPENed",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=$IO
 C ^V1A("CLOSE"),^V1B("CLOSE")
 S ^VCOMP=VCOMP,^VCORR=$IO D ^VEXAMINE
 ;
645 W !,"I-645  Format of $JOB"
 S ^ABSN="12148",^ITEM="I-645  Format of $JOB",^NEXT="END^VV1" D ^V1PRESET
 K ^V1F F I=1:1 Q:$D(^V1F)  H 1
 S ^VCOMP=$JOB?1N.N_" "_($J?1"0".N)_" "_(^V1A(2,1)?1N.N)_" "_(^V1A(2,1)?1"0".N)
 S ^VCORR="1 0 1 0" D ^VEXAMINE
 ;
646 W !,"I-646  Value of $JOB on two partitions"
 ;(test corrected in V7.4;16/9/89)
 S ^ABSN="12149",^ITEM="I-646  Value of $JOB on two partitions",^NEXT="END^VV1" D ^V1PRESET
 S ^VCOMP=($JOB=$J)_(^V1A(2,1)=^V1A(2,2))_($J=^V1A(2,1))
 S ^VCORR="110" D ^VEXAMINE
 ;
647 W !,"I-647  Consistency of $IO values"
 ;(test corrected in V7.4;16/9/89)
 S ^ABSN="12150",^ITEM="I-647  Consistency of $IO values",^NEXT="END^VV1" D ^V1PRESET
 K ^V1F F I=1:1 Q:$D(^V1F)  H 1
 S VCOMP=(^V1C(1,1)=^V1C(1,2))_(^V1C(2,1)=^V1C(2,2)) ;11
 S VCOMP=VCOMP_($IO=$I)_(^V1A(2,3)=^V1A(2,4)) ;11
 S VCOMP=VCOMP_(^V1C(1,1)=^V1C(2,1)) ;0
 S VCOMP=VCOMP_($I=^V1A(2,3)) ;0
 S VCOMP=VCOMP_(^V1C(1,1)=$I) ;1
 I ^V1A(2,3)="" S VCOMP=VCOMP_1
 E  S VCOMP=VCOMP_(^V1C(2,1)=^V1A(2,3)) ;1
 S ^VCOMP=VCOMP,^VCORR="11110011" D ^VEXAMINE
 ;
END W !!,"End of 196---V1MJA2",!
 K ^V1A,^V1B,^V1F,^V1C K  L  Q
 ;
HANG F I=1:1 Q:$D(^V1F)  H 1
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
