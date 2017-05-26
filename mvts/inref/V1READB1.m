V1READB1 ;IW-KO-TS,V1READB,MVTS V9.10;15/6/96;READ, $TEST AND READ ARGUMENT INDIRECTION -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"185---V1READB1: READ, $TEST and READ argument indirection -1-",!
 W !,"READ WITH TIMEOUT",!
 ;
760 W !,"I-760/761/762  timeout is equal to 0 or less than 0"
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 I 1 ;(test corrected in V7.3;20/6/88)
 W !,"Don't touch any key till I-763/764 appears in a few seconds."
 W !,"If not, the system must have hung up!" ;(message changed V7.5;20/8/90)
7601 S ^ABSN="12065",^ITEM="I-760/761/762.1  READ lvn timeout and timeout is equal to 0",^NEXT="7602^V1READB1,V1READB2^V1READB,V1HANG^VV1" D ^V1PRESET
 S VCOMP=""
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 I 1 ;(test corrected in V7.3;20/6/88)
 K A R !!,"   R A:0",A:0 S VCOMP=$D(A)_" "_$T_" "_A_" "_(A="")
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCOMP=VCOMP,^VCORR="1 0  1" D ^VEXAMINE
 ;
7602 S ^ABSN="12066",^ITEM="I-760/761/762.2  READ *lvn timeout and timeout is equal to 0",^NEXT="7603^V1READB1,V1READB2^V1READB,V1HANG^VV1" D ^V1PRESET
 S ^VCOMP="" K A
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 I 1 ;(test corrected in V7.3;20/6/88)
 READ !!,"   READ *A:0",*A:0
 S ^VCOMP=$D(A)_" "_$T_" "_A_" "_(A=-1) S ^VCORR="1 0 -1 1"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D ^VEXAMINE
 ;
7603 S ^ABSN="12067",^ITEM="I-760/761/762.3  READ lvn timeout and timeout is less than 0",^NEXT="7604^V1READB1,V1READB2^V1READB,V1HANG^VV1" D ^V1PRESET
 S ^VCOMP=""
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 I 1 K A ;(test corrected in V7.3;20/6/88)
 R !!,"   R A:-1",A:-1
 S ^VCOMP=$D(A)_" "_$T_" "_A_" "_(A="") S ^VCORR="1 0  1"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D ^VEXAMINE
 ;
7604 S ^ABSN="12068",^ITEM="I-760/761/762.4  READ *lvn timeout and timeout is less than 0",^NEXT="V1READB2^V1READB,V1HANG^VV1" D ^V1PRESET
 S ^VCOMP=""
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 I 1 K A ;(test corrected in V7.3;20/6/88)
 R !!,"   R *A:-1",*A:-1 S ^VCOMP=$D(A)_" "_$T_" "_A_" "_(A=-1)
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCORR="1 0 -1 1" D ^VEXAMINE
 ;
END W !!,"End of 185---V1READB1",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
