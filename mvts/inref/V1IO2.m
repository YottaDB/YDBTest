V1IO2 ;IW-KO-MM-TS,V1IO,MVTS V9.10;15/6/96;I/O CONTROL -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
542 W !,"I-542  Effect on $X by output of graphics"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12118",^ITEM="I-542  Effect on $X by output of graphics",^NEXT="543^V1IO2,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=XCOR(4)_"/"_XCOR(5)_"/"_XCOR(7)
 S ^VCORR=3_"/"_19_"/"_3
 D ^VEXAMINE
 ;
543 W !,"I-543  Effect on $Y by output of graphics"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12119",^ITEM="I-543  Effect on $Y by output of graphics",^NEXT="544^V1IO2,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=YCOR(4)_"/"_YCOR(5)_"/"_YCOR(7)
 S ^VCORR=4_"/"_4_"/"_5
 D ^VEXAMINE
 ;
544 W !,"I-544  Effect on $X by output of format parameter"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12120",^ITEM="I-544  Effect on $X by output of format parameter",^NEXT="545^V1IO2,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=XCOR(2)_"/"_XCOR(3)
 S ^VCORR=0_"/"_10
 D ^VEXAMINE
 ;
545 W !,"I-545  Effect on $Y by output of format parameter"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12121",^ITEM="I-545  Effect on $Y by output of format parameter",^NEXT="546^V1IO2,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=YCOR(2)_"/"_YCOR(3)
 S ^VCORR=2_"/"_3
 D ^VEXAMINE
 ;
546 W !,"I-546  $X in executing USE command"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12122",^ITEM="I-546  $X in executing USE command",^NEXT="547^V1IO2,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=XCOR(1)_"/"_XCOR(6)_"/"
 IF IO(550)'="" S ^VCOMP=^VCOMP_XCOR(8)
 I  S ^VCORR=4_"/"_19_"/"_4
 E  S ^VCORR=4_"/"_19_"/"
 D ^VEXAMINE
 ;
547 W !,"I-547  $Y in executing USE command"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12123",^ITEM="I-547  $Y in executing USE command",^NEXT="548^V1IO2,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=YCOR(1)_"/"_YCOR(6)_"/"
 IF IO(550)'="" S ^VCOMP=^VCOMP_YCOR(8)
 I  S ^VCORR=3_"/"_4_"/"_3
 E  S ^VCORR=3_"/"_4_"/"
 D ^VEXAMINE
 ;
548 W !,"I-548  $IO and OPEN command"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12124",^ITEM="I-548  $IO and OPEN command",^NEXT="549^V1IO2,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=IO(548),^VCORR=IO(0) D ^VEXAMINE
 ;
549 W !,"I-549  $IO and USE command"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12125",^ITEM="I-549  $IO and USE command",^NEXT="550^V1IO2,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=IO(5491)_IO(5490)_IO(5492)
 S ^VCORR=X_IO(0)_X D ^VEXAMINE
 ;
550 W !,"I-550  $IO and CLOSE command"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12126",^ITEM="I-550  $IO and CLOSE command",^NEXT="551^V1IO2,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=IO(550)
 S ^VCORR="" IF IO(550)'="" S ^VCORR=IO(0)
 D ^VEXAMINE
 ;
551 W !,"I-551  $JOB and OPEN command"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12127",^ITEM="I-551  $JOB and OPEN command",^NEXT="552^V1IO2,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=JOB(551),^VCORR=JOB(0) D ^VEXAMINE
 ;
552 W !,"I-552  $JOB and USE command"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12128",^ITEM="I-552  $JOB and USE command",^NEXT="553^V1IO2,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=JOB(5521)_JOB(5520)_JOB(5522)
 S ^VCORR=JOB(0)_JOB(0)_JOB(0) D ^VEXAMINE
 ;
553 W !,"I-553  $JOB and CLOSE command"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12129",^ITEM="I-553  $JOB and CLOSE command",^NEXT="554^V1IO2,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=JOB(553),^VCORR=JOB(0) D ^VEXAMINE
 ;
554 W !,"I-554  $JOB and current I/O device"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12130",^ITEM="I-554  $JOB and current I/O device",^NEXT="V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=""
 F I=532,533,534,5380,5381,5390,5391,5400,5401,5411,5412,5413,551,5521,5520,5522,553 S ^VCOMP=^VCOMP_(JOB(0)=JOB(I))
 S ^VCORR="11111111111111111" D ^VEXAMINE
 ;
END QUIT
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
