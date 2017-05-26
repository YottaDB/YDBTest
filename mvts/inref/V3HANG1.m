V3HANG1 ;IW-KO-TS,VV3,MVTS V9.10;15/6/96;HANG COMMAND  -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"       Moved from V1HANG1"
 W !!,"23---V3HANG1: HANG command  -1-",!
 ;
 ; Due to system load issues, a HANG command could return a lot longer than the specified hang time.
 ; To avoid false test failures due to this, we check for the elapsed time to be within 50% to 150% of the expected hang time.
 ; If ever the elapsed time is 50% lesser than the expected time we error out right away as that is a bug in the HANG command.
 ; 	(For tests that do HANG 0 or negative values the expected elapsed time is 0 or 1 so we dont do a < test in those cases).
 ; But if the elapsed time is 50% greater than the expected time, we retry for a max of 5 times before erroring out finally.
 NEW MAXTRIES
 S MAXTRIES=5
 ;
1 W !!,"I,III-313  HANG duration by $H"
 S ^ABSN="30313",^ITEM="I,III-313  HANG duration by $H"
 S ^NEXT="2^V3HANG1,V3HANG2^V3HANG,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="HANG 10",TM=10 D START HANG 10 D STOP
 . IF (H<(TM*.5)) S ^VCOMP="ERROR"
 . ELSE  IF (H<(TM*1.5)) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
2 W !!,"I,III-314  List of hangargument"
 S ^ABSN="30314",^ITEM="I,III-314  List of hangargument"
 S ^NEXT="3^V3HANG1,V3HANG2^V3HANG,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="H 0,1,2,3",TM=6 D START H 0,1,2,3 D STOP
 . IF (H<(TM*.5)) S ^VCOMP="ERROR"
 . ELSE  IF (H<(TM*1.5)) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
3 W !!,"I,III-315  HANG in FOR scope"
 S ^ABSN="30315",^ITEM="I,III-315  HANG in FOR scope"
 S ^NEXT="4^V3HANG1,V3HANG2^V3HANG,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="F I=1:1:2 H 5",TM=10 D START F I=1:1:2 H 5
 . D STOP ;(test changed in V7.5;20/8/90)
 . IF (H<(TM*.5)) S ^VCOMP="ERROR"
 . ELSE  IF (H<(TM*1.5)) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
4 W !!,"I,III-316  HANG with postconditional"
 S ^ABSN="30316",^ITEM="I,III-316  HANG with postconditional"
 S ^NEXT="5^V3HANG1,V3HANG2^V3HANG,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="H:1+1 5",TM=5 D START H:1+1 5 D STOP
 . IF (H<(TM*.5)) S ^VCOMP="ERROR"
 . ELSE  IF (H<(TM*1.5)) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
5 W !!,"I,III-317  Argument level indirection"
 S ^ABSN="30317",^ITEM="I,III-317  Argument level indirection"
 S ^NEXT="6^V3HANG1,V3HANG2^V3HANG,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="S A=3 H @1,@A",TM=4,A=3 D START H @1,@A D STOP ;(test changed in V7.5;20/8/90)
 . IF (H<(TM*.5)) S ^VCOMP="ERROR"
 . ELSE  IF (H<(TM*1.5)) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
6 W !!,"I,III-318  Name level indirection"
 S ^ABSN="30318",^ITEM="I,III-318  Name level indirection"
 S ^NEXT="7^V3HANG1,V3HANG2^V3HANG,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="S A=""B"",B=6 H @A",TM=6,A="B",B=6 D START H @A D STOP ;(test changed in V7.5;20/8/90)
 . IF (H<(TM*.5)) S ^VCOMP="ERROR"
 . ELSE  IF (H<(TM*1.5)) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
7 W !!,"HANG numexpr"
 W !!,"I,III-319  numexpr is integer"
 S ^ABSN="30319",^ITEM="I,III-319  numexpr is integer"
 S ^NEXT="8^V3HANG1,V3HANG2^V3HANG,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="XECUTE ""H 5""",TM=5,X="H 5" D START XECUTE X D STOP
 . IF (H<(TM*.5)) S ^VCOMP="ERROR"
 . ELSE  IF (H<(TM*1.5)) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
8 W !!,"I,III-320  numexpr=0"
 S ^ABSN="30320",^ITEM="I,III-320  numexpr=0"
 S ^NEXT="V3HANG2^V3HANG,V3RAND^VV3" D ^V3PRESET
 S ^VCOMP="" for LCNT=1:1:MAXTRIES  DO  QUIT:$L(^VCOMP)
 . S CMD="H 0",TM=0 D START H 0 D STOP
 . IF (H=0)!(H=1) S ^VCOMP="OK" QUIT
 . ZSHOW "*"
 S:'$L(^VCOMP) ^VCOMP="ERROR"
 S ^VCORR="OK" D ^VEXAMINE
 ;
END W !!,"End of 23 --- V3HANG1",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
START S H(1)=$H Q
STOP S H(2)=$H,H=$$^difftime(H(2),H(1)) Q
