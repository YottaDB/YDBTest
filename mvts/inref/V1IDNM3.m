V1IDNM3 ;IW-KO-TS,V1IDNM,MVTS V9.10;15/6/96;NAME LEVEL INDIRECTION -3-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"148---V1IDNM3: Name level indirection -3-"
DATA W !!,"$DATA(@expratom)",!
509 W !,"I-509  Indirection of $DATA argument"
 S ^ABSN="11811",^ITEM="I-509  Indirection of $DATA argument",^NEXT="510^V1IDNM3,V1IDGO^VV1" D ^V1PRESET
 K ^V1A S ^V1A(0)=0,^(1)=1,^(2)=2,^(3)=3,^V1A(1,1)=11,^V1A(2,2)=22,^(2,2)=222
 S ^V1A(3,3)=33,^(3,3)=333,^(3,3,3)=33333
 S A="^V1A",B="^V1A(0)",C="^(1)",D="^(1,1)"
 S ^VCOMP=$D(@A)_" "_$D(@B)_" "_$D(@C)_" "_$D(@D),^VCORR="10 1 11 1" D ^VEXAMINE
 ;
510 W !,"I-510  Indirection of subscript"
 S ^ABSN="11812",^ITEM="I-510  Indirection of subscript",^NEXT="511^V1IDNM3,V1IDGO^VV1" D ^V1PRESET
 S ^VCOMP=""
 K ^V1A S ^V1A(0)=0,^(1)=1,^(2)=2,^(3)=3,^V1A(1,1)=11
 S ^V1A(2,2)=22,^(2,2)=222,^V1A(3,3)=33,^(3,3)=333,^(3,3,3)=33333
 S A="@B",B="^V1A(@G)",G="Y",Y=3,C="D",D=3
 S ^VCOMP=^VCOMP_$D(^V1A(3,@C,@G,30/10))_" "_$D(^V1A(@A,3,@G))
 S ^VCORR="10 11" D ^VEXAMINE
 ;
511 W !,"I-511  2 levels of indirection"
 S ^ABSN="11813",^ITEM="I-511  2 levels of indirection",^NEXT="512^V1IDNM3,V1IDGO^VV1" D ^V1PRESET
 S ^VCOMP=""
 K ^V1A S ^V1A(0)=0,^(1)=1,^(2)=2,^(3)="^V1A",^V1A(1,1)=11
 S ^V1A(2,2)=22,^(2,2)=222,^V1A(3,3)=33,^(3,3)=333,^(3,3,3)=33333
 S A="@B",B="@^V1A(@Y)",G="Y",Y="Z",Z=3,H="^V1A(@@G,3,@@G)"
 S ^VCOMP=^VCOMP_$D(@H)_" "_$DATA(@A),^VCORR="11 10" D ^VEXAMINE
 ;
512 W !,"I-512  3 levels of indirection"
 S ^ABSN="11814",^ITEM="I-512  3 levels of indirection",^NEXT="513^V1IDNM3,V1IDGO^VV1" D ^V1PRESET
 S ^VCOMP=""
 K ^V1A S ^V1A(0)=0,^(1)="^V1A(2,2,2)",^(2)=2,^(3)="@^V1A(1)",^V1A(1,1)=11
 S ^V1A(2,2)=22,^(2,2)=222,^V1A(3,3)=33,^(3,3)=333,^(3,3,3)=33333
 S A="@B",B="@^V1A(@@Y)",G="Y",Y="Z",Z="Q",Q=3,H="^V1A(@@@G,3,@@@G)"
 S ^VCOMP=^VCOMP_$D(@H)_" "_$DATA(@A),^VCORR="11 1" D ^VEXAMINE
 ;
513 W !!,"$NEXT(@expratom)",!
 W !,"I-513  Indirection of $NEXT argument"
 S ^ABSN="11815",^ITEM="I-513  Indirection of $NEXT argument",^NEXT="514^V1IDNM3,V1IDGO^VV1" D ^V1PRESET
 ;Rev. ANSI 84 20/8/92
 ;Withdr;Moved to Part-90;10/10/92
 W !,"       (This test I-513 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
514 W !,"I-514  Indirection of subscript"
 S ^ABSN="11816",^ITEM="I-514  Indirection of subscript",^NEXT="515^V1IDNM3,V1IDGO^VV1" D ^V1PRESET
 ;Rev. ANSI 84 20/8/92
 ;Withdr;Moved to Part-90;10/10/92
 W !,"       (This test I-514 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
515 W !,"I-515  Indirection of naked reference"
 S ^ABSN="11817",^ITEM="I-515  Indirection of naked reference",^NEXT="516^V1IDNM3,V1IDGO^VV1" D ^V1PRESET
 ;Rev. ANSI 84 20/8/92
 ;Withdr;Moved to Part-90;10/10/92
 W !,"       (This test I-515 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
516 W !,"I-516  2 levels of indirection"
 S ^ABSN="11818",^ITEM="I-516  2 levels of indirection",^NEXT="517^V1IDNM3,V1IDGO^VV1" D ^V1PRESET
 ;Rev. ANSI 84 20/8/92
 ;Withdr;Moved to Part-90;10/10/92
 W !,"       (This test I-516 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
517 W !,"I-517  3 levels of indirection"
 S ^ABSN="11819",^ITEM="I-517  3 levels of indirection",^NEXT="V1IDGO^VV1" D ^V1PRESET
 ;Rev. ANSI 84 20/8/92
 ;Withdr;Moved to Part-90;10/10/92
 W !,"       (This test I-517 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 148---V1IDNM3",!
 K  K ^V1A Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
NEXT K ^V1A
 S ^V1A(0)=0,^(1)=1,^V1A(1,1)=11,^V1A(1000,1000)=1000000
 S ^V1A(22,66)=2266,^V1A(22,44,66)=224466,^V1A(100)=100
