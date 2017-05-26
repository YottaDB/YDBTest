V1READB2 ;IW-KO-TS,V1READB,MVTS V9.10;15/6/96;READ, $TEST AND READ ARGUMENT INDIRECTION -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"186---V1READB2: READ, $TEST and READ argument indirection -2-",!
 ;
763 W !!,"I-763/764  Value of $TEST and lvn, when input is terminated"
7631 S ^ABSN="12069",^ITEM="I-763/764.1  READ lvn timeout",^NEXT="7632^V1READB2,V1READB3^V1READB,V1HANG^VV1" D ^V1PRESET
 S ^VCOMP="" K A
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 I 0 ;(test corrected in V7.3;20/6/88)
 R !!,"   R A:100  ; Type 2 characters 'AB' and a <CR> within 100 seconds : ",A:100
 S ^VCOMP=$D(A)_" "_$TEST_" "_A_" "_(A="AB"),^VCORR="1 1 AB 1"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G 763
 D ^VEXAMINE
 ;
7632 S ^ABSN="12070",^ITEM="I-763/764.2  READ *lvn timeout",^NEXT="765^V1READB2,V1READB3^V1READB,V1HANG^VV1" D ^V1PRESET
 S ^VCOMP="" K A
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 I 0 ;(test corrected in V7.3;20/6/88)
 R !!,"R *A:100 ;Type one character 'A' within 100 seconds and NEVER touch <CR> : ",*A:100
 S ^VCOMP=$D(A)_" "_$T_" "_A_" "_(A=65),^VCORR="1 1 65 1"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G 7632
 D ^VEXAMINE
 ;
765 W !!,"I-765/766  Value of $TEST and lvn, when input is not terminated"
7651 S ^ABSN="12071",^ITEM="I-765/766.1  READ lvn timeout",^NEXT="7652^V1READB2,V1READB3^V1READB,V1HANG^VV1" D ^V1PRESET
 S ^VCOMP="" K A
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 I 1 ;(test corrected in V7.3;20/6/88)
 R !!," R A:10 ; Type 2 characters 'AB' within 10 seconds and NEVER touch <CR> : ",A:10
 S ^VCOMP=$D(A)_" "_$T_" "_A_" "_(A="AB") S ^VCORR="1 0 AB 1"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G 765
 D ^VEXAMINE
 ;
7652 S ^ABSN="12072",^ITEM="I-765/766.2  An empty string",^NEXT="V1READB3^V1READB,V1HANG^VV1" D ^V1PRESET
 S ^VCOMP="" K %A
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 I 0 ;(test corrected in V7.3;20/6/88)
 R !!,"   R %A:10  ; Type only a <CR>  within 10 seconds : ",%A:10
 S ^VCOMP=$D(%A)_" "_$T_" "_%A_" "_(%A="") S ^VCORR="1 1  1"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G 7652
 D ^VEXAMINE
 ;
END W !!,"End of 186---V1READB2",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
