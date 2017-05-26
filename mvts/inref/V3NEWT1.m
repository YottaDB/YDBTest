V3NEWT1 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"105---V3NEWMT1: NEW -35-"
 W !!,"duplicated NEW in a DO command"
 W !!,"2 times"
 ;
75 S ^ABSN="30982",^ITEM="III-0982  $D(lvn)=0"
 S ^NEXT="76^V3NEWT1,V3NEWT2^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 D NEWT21,CHECK
 S ^VCORR="11 1 1 0 10 1 11 1 aa(2)bc(2)dd(2)#11 1 10 1 1 0 0 0 aaaa(2)bb(2)cc#11 1 1 0 0 0 0 0 aaaa(2)b#"
 D ^VEXAMINE
 ;
76 S ^ABSN="30983",^ITEM="III-0983  $D(lvn)=1"
 S ^NEXT="^V3NEWT2,V3NEWT3^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",B="B",C="C"
 D NEWT22,CHECK
 S ^VCORR="11 1 1 0 11 1 1 0 aa(2)bCc(2)d#10 1 11 1 11 1 10 1 aa(2)bbb(2)Ccc(2)dd(2)#11 1 1 0 11 1 1 0 aa(2)BCcc(2)d#"
 D ^VEXAMINE
 ;
END W !!,"End of 105 --- V3NEWT1",!
 K  Q
 ;
NEWT21 ;
 N (A,B)
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK
 NEW C,B kill D
 S A="aa",A(2)="aa(2)",B(2)="bb(2)",C="cc"
 D CHECK
 Q
 ;
NEWT22 ;
 NEW B
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d"
 D CHECK
 N (B,C)
 S A(2)="aa(2)",B(2)="bb(2)",C(2)="cc(2)",D(2)="dd(2)"
 D CHECK
 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
CHECK ;
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)
 S ^VCOMP=^VCOMP_"#"
 Q
