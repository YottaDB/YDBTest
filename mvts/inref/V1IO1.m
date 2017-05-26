V1IO1 ;IW-KO-MM-TS,V1IO,MVTS V9.10;15/6/96;I/O CONTROL -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
532 W !,"I-532/535  OPEN command syntax and operation"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12111",^ITEM="I-532/535  OPEN command syntax and operation",^NEXT="533^V1IO1,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=JOB(532)_"/"_IO(532)_"/"_XCOR(532)_"/"_YCOR(532)
 S ^VCORR=JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)
 D ^VEXAMINE
 ;
533 W !,"I-533/536  USE command syntax and operation"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12112",^ITEM="I-533/536  USE command syntax and operation",^NEXT="534^V1IO1,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=JOB(533)_"/"_IO(533)_"/"_XCOR(533)_"/"_YCOR(533)
 I $P(X("USE"),":",1)?1.N S X=+$P(X("USE"),":",1)
 I $P(X("USE"),":",1)?1""""1.ANP1"""" S X=$P(X("USE"),":",1),X=$E(X,2,$L(X)-1)
 E  S X=IO(533)
 S ^VCORR=JOB(0)_"/"_X_"/"_0_"/"_0
 D ^VEXAMINE
 ;
534 W !,"I-534/537  CLOSE command syntax and operation"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12113",^ITEM="I-534/537  CLOSE command syntax and operation",^NEXT="538^V1IO1,V1MJA^VV1" D ^V1PRESET
 IF IO(534)="" S ^VCOMP=JOB(534)_"/"_IO(534)
 E  S ^VCOMP=JOB(534)_"/"_IO(534)_"/"_XCOR(534)_"/"_YCOR(534)
 I  S ^VCORR=JOB(0)_"/"
 E  S ^VCORR=JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)
 D ^VEXAMINE
 ;
538 W !,"I-538  Postconditional of OPEN command"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12114",^ITEM="I-538  Postconditional of OPEN command",^NEXT="539^V1IO1,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=""
 S ^VCOMP=^VCOMP_JOB(5380)_"/"_IO(5380)_"/"_XCOR(5380)_"/"_YCOR(5380)_"/"
 S ^VCOMP=^VCOMP_JOB(5381)_"/"_IO(5381)_"/"_XCOR(5381)_"/"_YCOR(5381)
 S ^VCORR=JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)_"/"_JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)
 D ^VEXAMINE
 ;
539 W !,"I-539  Postconditional of USE command"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12115",^ITEM="I-539  Postconditional of USE command",^NEXT="540^V1IO1,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=""
 S ^VCOMP=^VCOMP_JOB(5390)_"/"_IO(5390)_"/"_XCOR(5390)_"/"_YCOR(5390)_"/"
 S ^VCOMP=^VCOMP_JOB(5391)_"/"_IO(5391)_"/"_XCOR(5391)_"/"_YCOR(5391)
 S ^VCORR=JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)_"/"_JOB(0)_"/"_X_"/"_0_"/"_0
 D ^VEXAMINE
 ;
540 W !,"I-540  Postconditional of CLOSE command"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12116",^ITEM="I-540  Postconditional of CLOSE command",^NEXT="541^V1IO1,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=""
 IF IO(5401)="" S ^VCOMP=^VCOMP_JOB(5400)_"/"_IO(5400)_"/"_XCOR(5400)_"/"_YCOR(5400)_"/"_JOB(5401)
 E  S ^VCOMP=^VCOMP_JOB(5400)_"/"_IO(5400)_"/"_XCOR(5400)_"/"_YCOR(5400)_"/"
 E  S ^VCOMP=^VCOMP_JOB(5401)_"/"_IO(5401)_"/"_XCOR(5401)_"/"_YCOR(5401)
 I  S ^VCORR=JOB(0)_"/"_X_"/"_0_"/"_0_"/"_JOB(0)
 E  S ^VCORR=JOB(0)_"/"_X_"/"_0_"/"_0_"/"_JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)
 D ^VEXAMINE
 ;
541 W !,"I-541  timeout of OPEN command"
 ;(test corrected in V7.3;20/6/88)
 S ^ABSN="12117",^ITEM="I-541  timeout of OPEN command",^NEXT="542^V1IO2,V1MJA^VV1" D ^V1PRESET
 S ^VCOMP=""
 S ^VCOMP=^VCOMP_JOB(5411)_"/"_IO(5411)_"/"_XCOR(5411)_"/"_YCOR(5411)_"/"_T(5411)_"/"
 S ^VCOMP=^VCOMP_JOB(5412)_"/"_IO(5412)_"/"_XCOR(5412)_"/"_YCOR(5412)_"/"_T(5412)_"/"
 IF IO(5413)="" S ^VCOMP=^VCOMP_JOB(5413)_"/"_IO(5413)_"/"_T(5413)
 E   S ^VCOMP=^VCOMP_JOB(5413)_"/"_IO(5413)_"/"_XCOR(5413)_"/"_YCOR(5413)_"/"_T(5413)
 S ^VCORR=JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)_"/"_1_"/"_JOB(0)_"/"_X_"/"_0_"/"_0_"/"_1_"/"
 I  S ^VCORR=^VCORR_JOB(0)_"/"_IO(0)_"/"_1
 E  S ^VCORR=^VCORR_JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)_"/"_1
 D ^VEXAMINE
 ;
END QUIT
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
