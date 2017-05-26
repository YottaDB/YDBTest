V1IDARG5 ;IW-KO-MM-YS-TS,V1IDARG,MVTS V9.10;15/6/96;ARGUMENT LEVEL INDIRECTION -5-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"157---V1IDARG5: Argument level indirection -5-"
WRITE W !!,"WRITE command" W:$Y>55 #
 ;
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 W !,"This routine (157---V1IDARG5) contains 9 tests to be checked by OPERATOR."
REP W !!,"When you are ready, press ""Y/y"" and a <CR> : " S Y="Y"
 IF Y="Y" GOTO REP1
 IF Y="y" GOTO REP1
 GOTO REP
REP1 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 ;
444 S ^ABSN="11875",^ITEM="I-444  Indirection of writeargument except format (by OPERATOR)",^NEXT="445^V1IDARG5,V1IDARG6^V1IDARG,V1XECA^VV1" W !!,^ITEM D ^V1PRESET
 W !,"       Following two lines should be identical:"
 S A="B",B="WRITE"
 W !,"   WRITE"
 W !?3,@A
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 444
 ;
445 S ^ABSN="11876",^ITEM="I-445  Indirection of writeargument list (by OPERATOR)",^NEXT="446^V1IDARG5,V1IDARG6^V1IDARG,V1XECA^VV1" W !!,^ITEM D ^V1PRESET
 W !,"       Following two lines should be identical:"
 S A="B",B=" ** ",C="""DOT"""
 W !,"    **  ** DOT"
 W !?3,@A,@A,@C
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 445
 ;
446 S ^ABSN="11877",^ITEM="I-446  Indirection of format control parameters (by OPERATOR)",^NEXT="447^V1IDARG5,V1IDARG6^V1IDARG,V1XECA^VV1" W !!,^ITEM D ^V1PRESET
 W !,"       Following two lines should be identical:"
 S A="!?3,""AB"""
 W !,"   AB" W @A
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 446
 ;
447 S ^ABSN="11878",^ITEM="I-447  2 levels of writeargument indirection (by OPERATOR)",^NEXT="448^V1IDARG5,V1IDARG6^V1IDARG,V1XECA^VV1" W !!,^ITEM D ^V1PRESET
 W !,"       Following two lines should be identical:"
 S B(1)="@B(2),@B(3)",B(2)="!?3,1",B(3)="?3,B(4)",B(4)=" LINE"
 S C="C(1)",C(1)="C(2)",C(2)=" PAGE"
 W !,"   1 LINE PAGE"
 W @B(1),@@C
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 447
 ;
448 S ^ABSN="11879",^ITEM="I-448  3 levels of writeargument indirection (by OPERATOR)",^NEXT="449^V1IDARG5,V1IDARG6^V1IDARG,V1XECA^VV1" W !!,^ITEM D ^V1PRESET
 W !,"       Following two lines should be identical:"
 K B,C
 S B="B(1)",B(1)="B(2)",B(2)="?3,B(3)_B(4)",B(3)="#",B(4)="%% "
 S C="@C(1),@C(2)",C(1)="@C(3)",C(2)="@C(4)",C(3)="D,D+D",C(4)="$E(0.123,2,3)"
 S D=12.3
 W !,"   #%% 12.324.612"
 W !,@@@B,@C
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 448
 ;
449 S ^ABSN="11880",^ITEM="I-449  Value of indirection contains name level indirection (by OPERATOR)",^NEXT="450^V1IDARG5,V1IDARG6^V1IDARG,V1XECA^VV1" W !!,^ITEM D ^V1PRESET
 W !,"       Following two lines should be identical:"
 W !,"   101"
 S A="@B+1",B="C",C=100
 W !?3,@A
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 449
 ;
450 S ^ABSN="11881",^ITEM="I-450  Value of indirection contains operators (by OPERATOR)",^NEXT="451^V1IDARG5,V1IDARG6^V1IDARG,V1XECA^VV1" W !!,^ITEM D ^V1PRESET
 W !,"       Following two lines should be identical:"
 W !?3,1
 W !?3,@''10
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 450
 ;
451 S ^ABSN="11882",^ITEM="I-451  Value of indirection contains function (by OPERATOR)",^NEXT="452^V1IDARG5,V1IDARG6^V1IDARG,V1XECA^VV1" W !!,^ITEM D ^V1PRESET
 W !,"       Following two lines should be identical:"
 S BC(1)="*****"
 W !,"   *****"
 W !?3,@($E("ABCDEFGHIJK",2,3)_"(1)")
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 451
 ;
452 S ^ABSN="11883",^ITEM="I-452  Value of indirection is numeric literal (by OPERATOR)",^NEXT="V1IDARG6^V1IDARG,V1XECA^VV1" W !!,^ITEM D ^V1PRESET
 W !,"       Following two lines should be identical:"
 W !,"   987.56"
 S A="+09875.600E-1" W !?3,@A
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 452
 ;
END W !!,"End of 157---V1IDARG5",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
