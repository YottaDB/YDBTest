V1READB3 ;IW-KO-TS,V1READB,MVTS V9.10;15/6/96;READ, $TEST and READ ARGUMENT INDIRECTION -3-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"187---V1READB3: READ, $TEST and READ argumrnt indirection -3-",!
 W !!,"READ argument indirection"
767 W !!,"I-767  Indirection of readargument except format"
 S ^ABSN="12073",^ITEM="I-767  Indirection of readargument except format",^NEXT="768^V1READB3,V1READB4^V1READB,V1HANG^VV1" D ^V1PRESET
 K A
 S D="""   R A   ; Type 5 characters 'MUMPS' and a <CR> : "",A"
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !!,@D
 S ^VCOMP=$D(A)_" "_A_" "_(A="MUMPS"),^VCORR="1 MUMPS 1"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G 767
 D ^VEXAMINE
 ;
768 W !!,"I-768  Indirection of readargument list"
 S ^ABSN="12074",^ITEM="I-768  Indirection of readargument list",^NEXT="769^V1READB3,V1READB4^V1READB,V1HANG^VV1" D ^V1PRESET
 K  S D="""   R A    ; Type 3 characters 'YES' and a <CR> : "",A"
 S E="!,""   R A(1) ; Type 3 characters 'yes' and a <CR> : "",A(1)"
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !!,@D,@E
 S ^VCOMP=$D(A)_" "_A_" "_(A="YES")
 S ^VCOMP=^VCOMP_"/"_$D(A(1))_" "_A(1)_" "_(A(1)="yes")
 S ^VCORR="11 YES 1/1 yes 1"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G 768
 D ^VEXAMINE
 ;
769 W !!,"I-769  Indirection of format control parameters"
 S ^ABSN="12075",^ITEM="I-769  Indirection of format control parameters",^NEXT="770^V1READB3,V1READB4^V1READB,V1HANG^VV1" D ^V1PRESET
 S VCOMP=""
 S F="!?3,""ABC"",!"
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 W !,"Type the same string as the next line that has preceding 3 spaces, and a <CR> :" ;(test corrected in V7.3;20/6/88)
 R @F,VCOMP
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCOMP=VCOMP,^VCORR="   ABC"
 D AGAIN^VEXAMINE I RES="YES" G 769
 D ^VEXAMINE
 ;
770 W !!,"I-770  2 levels of readargument indirection"
 S ^ABSN="12076",^ITEM="I-770  2 levels of readargument indirection",^NEXT="V1READB4^V1READB,V1HANG^VV1" D ^V1PRESET
 S A="!!,""   R A(2)    ; Type 2 characters 'NO' and a <CR> : "",@A(1)",A(1)="A(2)"
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R @A
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCOMP=A(2)_(A(2)="NO"),^VCORR="NO1"
 D AGAIN^VEXAMINE I RES="YES" G 770
 D ^VEXAMINE
 ;
END W !!,"End of 187---V1READB3",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
