V1PCA ;IW-YS-MM-TS,V1PC,MVTS V9.10;15/6/96;POST-CONDITIONALS -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"136---V1PCA: Post conditionals -1-",! W:$Y>55 #
 ;
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 W !,"This routine (136---V1PCA) contains 2 tests to be checked by OPERATOR."
REP W !!,"When you are ready, press ""Y/y"" and a <CR> : " S Y="Y"
 IF Y="Y" GOTO REP1
 IF Y="y" GOTO REP1
 GOTO REP
REP1 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 ;
712 W !,"I-712  WRITE command"
7121 S ^ABSN="11711",^ITEM="I-712.1  Postcondition contains = operator (by OPERATOR)",^NEXT="7122^V1PCA,V1PCB^V1PC,V1FORA^VV1" D ^V1PRESET
 W:$Y>55 #
 W !,"       Following two lines should be identical:"
 W !,"   Postcondition pass  "
 WRITE:1=1 !,"   Postcondition pass  " W:1=2 !,"** Postcondition FAIL  "
 WRITE:1=2 !,"** Postcondition FAIL  "
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 712
 ;
7122 S ^ABSN="11712",^ITEM="I-712.2  Postcondition contains lvn (by OPERATOR)",^NEXT="713^V1PCA,V1PCB^V1PC,V1FORA^VV1" D ^V1PRESET
 W:$Y>55 #
 W !,"       Following two lines should be identical:"
 W !,"   lvn PASS  "
 S PC=2 W:PC=1 !,"** lvn FAIL  " W:PC=2 !,"   lvn PASS  "
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 7122
 ;
713 W !,"I-713  SET command"
7131 S ^ABSN="11713",^ITEM="I-713.1  Local",^NEXT="7132^V1PCA,V1PCB^V1PC,V1FORA^VV1" D ^V1PRESET
 S ^VCOMP="",PC=2
 S ^VCOMP=^VCOMP_4 SET:1=1 ^VCOMP=^VCOMP_"C"
 S ^VCOMP=^VCOMP_"D" S:PC=1 ^VCOMP=^VCOMP_5
 S ^VCORR="4CD" D ^VEXAMINE
 ;
7132 S ^ABSN="11714",^ITEM="I-713.2  Global",^NEXT="V1PCB^V1PC,V1FORA^VV1" D ^V1PRESET
 S ^VCOMP="",^V1PC1=2 K ^V
 S:$D(^V)=0 ^V(1,2)=12 S ^VCOMP=^VCOMP_$D(^V)_" "_^V(1,2)_" "
 S:$D(^V(1))=0 ^V(3)=1 S ^VCOMP=^VCOMP_$D(^V(3))_" "
 S:^V1PC1=2 (A,B,C(1),D(20,21),^V)=110 S:^V1PC1=2.01 (A,B,^V)=10
 S ^VCOMP=^VCOMP_A_B_C(1)_D(20,21)_^V
 S ^VCORR="10 12 0 110110110110110" D ^VEXAMINE
 ;
END W !!,"End of 136---V1PCA",!
 K  K ^V,^V1PC1 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
