V1SET2 ;IW-KO-TS,VV1,MVTS V9.10;15/6/96;SET COMMAND  -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"122---V1SET2: SET command  -2-",!
 ;
785 W !,"I-785  Multiple-assigment of unsubscripted variables"
 S ^ABSN="11563",^ITEM="I-785  Multiple-assigment of unsubscripted variables",^NEXT="786^V1SET2,V1GO^VV1" D ^V1PRESET
 S ^VCOMP="" K A,B,C,D,E,F,^V1,^V1A
 S (A,B,C,D,E,F,^V1,^V1A)=1
 S ^VCOMP=A_B_C_D_E_F_^V1_^V1A K ^V1A
 S ^VCORR="11111111" D ^VEXAMINE
 ;
786 W !,"I-786  Multiple-assigment of subscripted variables"
 S ^ABSN="11564",^ITEM="I-786  Multiple-assigment of subscripted variables",^NEXT="787^V1SET2,V1GO^VV1" D ^V1PRESET
 S VCOMP="" K Z,^V1,Y
 S (A,B,C,D,E,F,^V1,^V1A)=1
 S (Z(1),Z(2,3),X,^V1(1),^V1(2,3),Y)="Z"
 S VCOMP=X_Y_Z(1)_Z(2,3)_^V1(1)_^V1(2,3)
 S (Q(A),B,^V1(1))=2
 S VCOMP=VCOMP_Q(A)_B_^V1(1) K ^V1A,^V1
 S ^VCOMP=VCOMP,^VCORR="ZZZZZZ222" D ^VEXAMINE
 ;
787 W !,"I-787  Execution sequence of SET command"
 S ^ABSN="11565",^ITEM="I-787  Execution sequence of SET command",^NEXT="V1GO^VV1" D ^V1PRESET
 S V=""
 S V=V_" " K ^V1A,^V1B S ^V1A(2)="A",^V1B(1)=^(2) S V=V_^V1A(2)_^V1B(1)
 S V=V_" " K ^V1A,^V1B S ^V1A(2)="B",^(1)=^V1A(2) S V=V_^V1A(2)_^V1A(1)
 S V=V_" " K ^V1A,^V1B S ^V1A(1,2)="C",^V1A(1)=0,^(1)=^(1,2) S V=V_^V1A(1)_^V1A(1,1)
 S V=V_" " K ^V1A,^V1B S ^V1A(1)=3,^V1A(2)="D",^V1B(^(1))=^(2) S V=V_^V1B(3)
 S V=V_" " K ^V1A,^V1B S ^V1A(2)="E",^V1B(1)=3,^(^(1))=^V1A(2) S V=V_^V1A(3)
 S V=V_" " K ^V1A,^V1B S ^V1A(1,2)=4,^(3)="F",^V1A(1)=5
 S ^V1B(^(1),^(1,2))=^(3) S V=V_^V1B(5,4)
 S V=V_" " K ^V1A,^V1B S ^V1B(2)=1,^V1B(3)="G",^V1A(1)=2
 S ^(^(1),^V1B(2))=^(3),^(5)="$" S V=V_^V1B(2,1)_^V1B(2,5)
 S V=V_" " K ^V1A,^V1B S ^V1B(2)=1,^V1B(2,3)="H",^V1B(2,1)=4,^V1A(1)=2
 S ^(^(^(1),^V1B(2)),1)=^(3),^(6)="%" S V=V_^V1B(2,4,1)_^V1B(2,4,6)
 S V=V_" " K A,B S A=1,B=2,(A,B,B(A,B))="I" S V=V_A_B_B(1,2)
 S V=V_" " K ^V1A,^V1B,^V1C,^V1D,^V1E S ^V1B(2)=2,^V1D(5)=5,^V1E(6,7)="J"
 S ^V1E(7)=7,^V1B(1,2)=8,^V1B(1,3)=3,^V1B(1,4)=4,^V1A(1)=1
 S (^(^(^(1),^V1B(2))),^V1C(^(3),4),^(^(4),^V1D(5)))=^(6,^V1E(7))
 S V=V_^V1E(6,8)_^V1C(3,4)_^V1C(3,4,5)
 S ^VCOMP=V,^VCORR=" AA BB 0C D E F G$ H% III JJJ" D ^VEXAMINE
 ;
END W !!,"End of 122---V1SET2",!
 K  K ^V1,^V1A,^V1B,^V1C,^V1D,^V1E Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
