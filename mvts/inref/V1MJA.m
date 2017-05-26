V1MJA ;IW-KO-TS,VV1,MVTS V9.10;15/6/96;LOCK, OPEN, CLOSE, $JOB, $IO and $TEST  SUB DRIVER
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W:$Y>45 #
 W !!,"V1MJA: Multi-job"
 W !!,"Tests of LOCK, OPEN, CLOSE, $JOB, $IO and $TEST"
V1MJA11 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 W !!,"  The following tests apply for Multi-job implementation by using LOCK"
 W !,"and un-LOCK, etc."
 W !,"  If this system is not a Multi-job implementation, the total 20 tests"
 W !,"will be skipped."
 W !,"  Do you want to skip the Multi-job tests (Y/N)? "
; R YN
 S YN="N"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 I YN="Y" Q
 I YN="N" G V1MJA0
 q
; G V1MJA11
V1MJA0 ;
 W !!,"  Type  DO ^V1MJB  and <CR> on another MUMPS partition (terminal)."
 W !,"If mistyped, you have another chance to type correctly after apperance"
 W !,"of the next direct-mode prompt."
 ;
V1MJA1 W !!,"195---V1MJA1" D ^V1MJA1
V1MJA2 W !!,"196---V1MJA2" D ^V1MJA2
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
SETPARA ;
 S ^V1A("OPEN")=^VENVIRON("#1 OPEN")
 S ^V1A("OPEN TIMEOUT")=^V1A("OPEN")
 I ^V1A("OPEN TIMEOUT")'[":(" S ^V1A("OPEN TIMEOUT")=^V1A("OPEN TIMEOUT")_":"
 S ^V1A("OPEN TIMEOUT")=^V1A("OPEN TIMEOUT")_":1"
 S ^V1A("USE")=^VENVIRON("#1 USE")
 S ^V1A("CLOSE")=^VENVIRON("#1 CLOSE")
 S ^V1B("OPEN")=^VENVIRON("#2 OPEN")
 S ^V1B("OPEN TIMEOUT")=^V1B("OPEN")
 I ^V1B("OPEN TIMEOUT")'[":(" S ^V1B("OPEN TIMEOUT")=^V1B("OPEN TIMEOUT")_":"
 S ^V1B("OPEN TIMEOUT")=^V1B("OPEN TIMEOUT")_":1"
 S ^V1B("USE")=^VENVIRON("#2 USE")
 S ^V1B("CLOSE")=^VENVIRON("#2 CLOSE")
 Q
