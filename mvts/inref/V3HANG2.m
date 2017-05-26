V3HANG2 ;IW-KO-TS,VV3,MVTS V9.10;15/6/96;HANG COMMAND -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"       Moved from V1HANG2"
 W !!,"24---V3HANG2: HANG command  -2-",!
 ;
 ; Due to system load issues, a HANG command could return a lot longer than the specified hang time.
 ; To avoid false test failures due to this, we check for the elapsed time to be within 50% to 150% of the expected hang time.
 ; If ever the elapsed time is 50% lesser than the expected time we error out right away as that is a bug in the HANG command.
 ; 	(For tests that do HANG 0 or negative values the expected elapsed time is 0 or 1 so we dont do a < test in those cases).
 ; But if the elapsed time is 50% greater than the expected time, we retry for a max of 5 times before erroring out finally.
 ;
 NEW MAXTRIES
 S MAXTRIES=5
 ;
1 W !!,"I,III-321  numexpr<0"
 ;W !!,"Don't touch any key till P/F question appears in a moment." ;(message added in V7.5;20/8/90)
 ;W !,"If not, the system must have halted!,",!
 S ^ABSN="30321",^ITEM="I,III-321  numexpr<0"
 S ^NEXT="2^V3HANG2,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="H -10",TM=0 D START H -10 D STOP
 . IF (H=0)!(H=1) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
2 W !!,"I,III-322  numexpr is non-integer positive numeric literal"
 S ^ABSN="30322",^ITEM="I,III-322  numexpr is non-integer positive numeric literal"
 S ^NEXT="3^V3HANG2,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="H 300E-2",TM=3 D START H 300E-2 D STOP ;(test changed in V7.5;20/8/90)
 . IF (H<(TM*.5)) S ^VCOMP="ERROR"
 . ELSE  IF (H<(TM*1.5)) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
3 W !!,"I,III-323  numexpr is greater than zero and less than one"
 S ^ABSN="30323",^ITEM="I,III-323  numexpr is greater than zero and less than one"
 S ^NEXT="4^V3HANG2,V3RAND^VV3" D ^V3PRESET
 W !,"     (This test I,III-323 was withdrawn in 15/2/1994 on X11.1-1990, MSL)"
 S ^VREPORT("Part-90",^ABSN)="*WITHDR*"
 ;
4 W !!,"I,III-324  numexpr is string literal"
 S ^ABSN="30324",^ITEM="I,III-324  numexpr is string literal"
 S ^NEXT="5^V3HANG2,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="H ""2ABCDE""",TM=2 D START H "2ABCDE" D STOP
 . IF (H<(TM*.5)) S ^VCOMP="ERROR"
 . ELSE  IF (H<(TM*1.5)) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
5 W !!,"I,III-325  numexpr is an empty string"
 S ^ABSN="30325",^ITEM="I,III-325  numexpr is an empty string"
 S ^NEXT="6^V3HANG2,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="H """"",TM=0 D START H "" D STOP
 . IF (H=0)!(H=1) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
6 W !!,"I,III-326  numexpr is lvn"
 S ^ABSN="30326",^ITEM="I,III-326  numexpr is lvn"
 S ^NEXT="7^V3HANG2,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="S A(2)=3 H A(2)",TM=3,A(2)=3 D START H A(2) D STOP
 . IF (H<(TM*.5)) S ^VCOMP="ERROR"
 . ELSE  IF (H<(TM*1.5)) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
7 W !!,"I,III-327  numexpr contains unary operator"
 ;W !!,"Don't touch any key till P/F question appears in a moment." ;(message added in V7.5;20/8/90)
 ;W !,"If not, the system must have halted!,",!
 S ^ABSN="30327",^ITEM="I,III-327  numexpr contains unary operator"
 S ^NEXT="8^V3HANG2,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="H -'0",TM=0 D START H -'0 D STOP
 . IF (H=0)!(H=1) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
8 W !!,"I,III-328  numexpr contains binary operator"
 S ^ABSN="30328",^ITEM="I,III-328  numexpr contains binary operator"
 S ^NEXT="V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="H 0_1_1",TM=11 D START H 0_1_1 D STOP
 . IF (H<(TM*.5)) S ^VCOMP="ERROR"
 . ELSE  IF (H<(TM*1.5)) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
END W !!,"End of 24 --- V3HANG2",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
START S H(1)=$H Q
STOP S H(2)=$H,H=$$^difftime(H(2),H(1)) Q
