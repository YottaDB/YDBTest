V3NEWI1 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"115---V3NEWI1: NEW -45-"
 W !!,"newargument is @expr"
 ;
96 S ^ABSN="31003",^ITEM="III-1003  @""A"""
 S ^NEXT="97^V3NEWI1,V3NEWI2^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 D NEWSEL1,CHECK
 S ^VCORR="000/11 1 1 0 10 1 0 0 aa(0,1,2)bc(0,1,2)#0 0 1 0 10 1 0 0 bc(0,1,2)#"
 D ^VEXAMINE
 ;
97 S ^ABSN="31004",^ITEM="III-1004  @B"
 S ^NEXT="98^V3NEWI1,V3NEWI2^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",B="B",C="C"
 D NEWSEL2,CHECK
 S ^VCORR="101/11 1 1 0 11 1 0 0 aa(0,1,2)bCc(0,1,2)#11 1 1 0 11 1 0 0 aa(0,1,2)BCc(0,1,2)#"
 D ^VEXAMINE
 ;
98 S ^ABSN="31005",^ITEM="III-1005  @$P(C,""("",1))"
 S ^NEXT="99^V3NEWI1,V3NEWI2^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A(0,1,2)="A(0,1,2)",B(0,1,2)="B(0,1,2)",C(0,1,2)="C(0,1,2)"
 D NEWSEL3,CHECK
 S ^VCORR="10100/11 1 11 1 10 1 0 0 aa(0,1,2)bB(0,1,2)c(0,1,2)#11 1 11 1 10 1 0 0 aa(0,1,2)bB(0,1,2)C(0,1,2)#"
 D ^VEXAMINE
 ;
99 S ^ABSN="31006",^ITEM="III-1006  @B(0,1,2)"
 S ^NEXT="^V3NEWI2,V3NEWI3^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",A(0,1,2)="A(0,1,2)",B="B",B(0,1,2)="@C",C="A",C(0,1,2)="C(0,1,2)"
 D NEWSEL4 D CHECK
 S ^VCORR="01111/11 1 11 1 11 1 0 0 aa(0,1,2)b@CAc(0,1,2)#11 1 11 1 11 1 0 0 AA(0,1,2)b@CAc(0,1,2)#"
 D ^VEXAMINE
 ;
END W !!,"End of 115 --- V3NEWI1",!
 K  Q
 ;
NEWSEL1 ;
 NEW @"A"
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;000/
 S A="a",A(0,1,2)="a(0,1,2)",B="b",C(0,1,2)="c(0,1,2)"
 D CHECK Q
 ;
NEWSEL2 ;
 NEW @B
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;101/
 S A="a",A(0,1,2)="a(0,1,2)",B="b",C(0,1,2)="c(0,1,2)"
 D CHECK Q
 ;
NEWSEL3 ;
 NEW @$P(C(0,1,2),"(",1)
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;10100/
 S A="a",A(0,1,2)="a(0,1,2)",B="b",C(0,1,2)="c(0,1,2)"
 D CHECK Q
 ;
NEWSEL4 ;
 NEW @B(0,1,2)
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;01111/
 S A="a",A(0,1,2)="a(0,1,2)",B="b",C(0,1,2)="c(0,1,2)"
 D CHECK Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
CHECK ;
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(0,1,2))_" "
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(0,1,2))_" "
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(0,1,2))_" "
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(0,1,2))_" "
 I $D(A)#10=1        S ^VCOMP=^VCOMP_A
 I $D(A(0,1,2))#10=1 S ^VCOMP=^VCOMP_A(0,1,2)
 I $D(B)#10=1        S ^VCOMP=^VCOMP_B
 I $D(B(0,1,2))#10=1 S ^VCOMP=^VCOMP_B(0,1,2)
 I $D(C)#10=1        S ^VCOMP=^VCOMP_C
 I $D(C(0,1,2))#10=1 S ^VCOMP=^VCOMP_C(0,1,2)
 I $D(D)#10=1        S ^VCOMP=^VCOMP_D
 I $D(D(0,1,2))#10=1 S ^VCOMP=^VCOMP_D(0,1,2)
 S ^VCOMP=^VCOMP_"#"
