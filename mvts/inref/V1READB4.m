V1READB4 ;IW-KO-TS,V1READB,MVTS V9.10;15/6/96;READ, $TEST and READ ARGUMENT INDIRECTION -4-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"188---V1READB4: READ, $TEST and READ argumrnt indirection -4-",!
 ;
771 W !!,"I-771  3 levels of readargument indirection"
 S ^ABSN="12077",^ITEM="I-771  3 levels of readargument indirection",^NEXT="772^V1READB4,V1HANG^VV1" D ^V1PRESET
 S B="!!,""   R B    ;"",@B(1)",B(1)=""" Type 2 characters 'no' and "",@B(2)",B(2)="""a <CR> : "",B"
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R @B
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCOMP=B_(B="no"),^VCORR="no1"
 D AGAIN^VEXAMINE I RES="YES" G 771
 D ^VEXAMINE
 ;
772 W !!,"I-772  Value of indirection contains indirection"
 S ^ABSN="12078",^ITEM="I-772  Value of indirection contains indirection",^NEXT="773^V1READB4,V1HANG^VV1" D ^V1PRESET
 S A(1)="@@A(2)",A(2)="A(3)",A(3)="A(@B(1))"
 S B(1)="@B(2)",B(2)="B(3)",B(3)=.4E1
 S A="!!,""   R A(3)    ; Type 4 characters 'BOOK' and a <CR> : "",@A(1)"
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R @A
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCOMP=A(4),^VCORR="BOOK"
 D AGAIN^VEXAMINE I RES="YES" G 772
 D ^VEXAMINE
 ;
773 W !!,"I-773  Value of indirection contains operators"
 S ^ABSN="12079",^ITEM="I-773  Value of indirection contains operators",^NEXT="774^V1READB4,V1HANG^VV1" D ^V1PRESET
 S A="!!,""   R AB:100    ; Type 3 characters 'ABC' and a <CR> within 100 seconds : "",@(A(1)_B(2)_"":100"")"
 S A(1)="A",B(2)="B"
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 I 0 ;(test corrected in V7.3;20/6/88)
 R @A S ^VCOMP=AB_$T ;(test corrected in V7.4;12/8/89)
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCORR="ABC1"
 D AGAIN^VEXAMINE I RES="YES" G 773
 D ^VEXAMINE
 ;
774 W !!,"I-774  Value of indirection is function"
 S ^ABSN="12080",^ITEM="I-774  Value of indirection is function",^NEXT="775^V1READB4,V1HANG^VV1" D ^V1PRESET
 S A="""   R A(3)    ; Type 8 characters 'Language' and a <CR> : """,I=3
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !!,@A,@$P("A(1)/A(2)/A(3)/A(4)","/",I) S ^VCOMP=A(3)
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCORR="Language"
 D AGAIN^VEXAMINE I RES="YES" G 774
 D ^VEXAMINE
 ;
775 W !!,"I-775  Value of indirection is lvn"
 S ^ABSN="12081",^ITEM="I-775  Value of indirection is lvn",^NEXT="V1HANG^VV1" D ^V1PRESET
 S A="!!,""   R A(12)    ; Type 2 characters 'OK' and a <CR>  : "",@A(@B)",A(2)="A(12)",B="B(1)",B(1)=2
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R @A
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCOMP=A(12),^VCORR="OK"
 D AGAIN^VEXAMINE I RES="YES" G 775
 D ^VEXAMINE
 ;
END W !!,"End of 188---V1READB4",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
