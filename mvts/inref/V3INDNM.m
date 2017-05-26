V3INDNM ;IW-KO-YS-TS,V3GET,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 ;
 W !!,"       Moved from V1IDNM3"
 W !!,"37---V3INDNM: Name level indirection"
 ;
1 W !!,"$ORDER(@expratom)",!
 W !,"I,III-30379  Indirection of $ORDER argument"
 S ^ABSN="30379",^ITEM="I,III-30379  Indirection of $ORDER argument"
 S ^NEXT="2^V3INDNM,V3QUERY^VV3" D ^V3PRESET
 ;Rev. ANSI 84 20/8/92
 D NEXT
 S B="^V1A(0)",C="^(1)",D="^(22,1)",E="^V1A(X)",X=30
 S F="^V1A(1000)",G="^V1A(2000)"
 S ^VCOMP=$ORDER(@B)_" "_$O(@C)_" "_$O(@D)_" "_$O(@E)_" "_$O(@F)_" "_$O(@G)
 S ^VCORR="1 22 44 100  " D ^VEXAMINE k ^V1A
 ;
2 W !,"I,III-30380  Indirection of subscript"
 S ^ABSN="30380",^ITEM="I,III-30380  Indirection of subscript"
 S ^NEXT="3^V3INDNM,V3QUERY^VV3" D ^V3PRESET
 ;Rev. ANSI 84 20/8/92
 D NEXT S A="A1",A1=0,B(1)="B(2)",B(2)=10,C="^V1A(@C(1))",C(1)="C(2)",C(2)=23
 S D="D(1)",D(1)="500"
 S ^VCOMP=$ORDER(^V1A(@A))_" "_$O(^(@B(1)))_" "_$O(^(22,@B(1)))_" "
 S ^VCOMP=^VCOMP_$O(@C)_" "_$O(^V1A(@D+@D))_" "_$O(^V1A(1000+1000))
 S ^VCORR="1 22 44 100  " D ^VEXAMINE K ^V1A
 ;
3 W !,"I,III-30381  Indirection of naked reference"
 S ^ABSN="30381",^ITEM="I,III-30381  Indirection of naked reference"
 S ^NEXT="4^V3INDNM,V3QUERY^VV3" D ^V3PRESET
 ;Rev. ANSI 84 20/8/92
 D NEXT S ^VCOMP=""
 S A="^(2)",B="^(22,"""")",C="^(44)"
 S ^VCOMP=$O(^V1A(""))_" "_$O(@A)_" "_$O(@B)_" "_$O(@C)
 S ^VCORR="0 22 44 66" D ^VEXAMINE K ^V1A
 ;
4 W !,"I,III-30382  2 levels of indirection"
 S ^ABSN="30382",^ITEM="I,III-30382  2 levels of indirection"
 S ^NEXT="5^V3INDNM,V3QUERY^VV3" D ^V3PRESET
 ;Rev. ANSI 84 20/8/92
 D NEXT S ^VCOMP=""
 S A="^V1A(@A(1))",A(1)="A(2)",A(2)="",B="@V1A(20)",V1A(20)="^V1A(500)"
 S C="C(1)",C(1)="^V1A(22,44,"""")"
 S ^VCOMP=$O(@A)_" "_$O(@B)_" "_$O(@@C)
 S ^VCORR="0 1000 66" D ^VEXAMINE K ^V1A
 ;
5 W !,"I,III-30383  3 levels of indirection"
 S ^ABSN="30383",^ITEM="I,III-30383  3 levels of indirection"
 S ^NEXT="V3QUERY^VV3" D ^V3PRESET
 ;Rev. ANSI 84 20/8/92
 D NEXT S ^VCOMP=""
 S A(0)="A(1)",A(1)="A(2)",A(2)="^V1A(1000,A(3))",A(3)=20
 S B(100)="@B(200)",B(200)="@B(300)",B(300)="^V1A(22,44,50)",B(4)=100
 S ^VCOMP=$O(@@@A(0))_" "_$O(@B(B(4)))
 S ^VCORR="1000 66" D ^VEXAMINE K ^V1A
 ;
END W !!,"End of 37 --- V3INDNM",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
NEXT K ^V1A
 S ^V1A(0)=0,^(1)=1,^V1A(1,1)=11,^V1A(1000,1000)=1000000
 S ^V1A(22,66)=2266,^V1A(22,44,66)=224466,^V1A(100)=100
