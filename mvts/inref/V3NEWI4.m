V3NEWI4 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"118---V3NEWI4: NEW -48-"
 ;
108 S ^ABSN="31015",^ITEM="III-1015  @""(A,B)"""
 S ^NEXT="109^V3NEWI4,V3NEWI5^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 D NEWEXC21,CHECK
 S ^VCORR="000/11 1 1 0 10 1 11 1 aa(2)bc(2)dd(2)#11 1 1 0 0 0 0 0 aa(2)b#"
 D ^VEXAMINE
 ;
109 S ^ABSN="31016",^ITEM="III-1016  @ZZZZZZZZ(""abcd"",""efg"",1,2,3,4)"
 S ^NEXT="110^V3NEWI4,V3NEWI5^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",B="B",C="C"
 D NEWEXC22,CHECK
 S ^VCORR="011/11 1 1 0 11 1 11 1 aa(2)bCc(2)dd(2)#1 0 1 0 11 1 0 0 AbCc(2)#"
 D ^VEXAMINE
 ;
110 S ^ABSN="31017",^ITEM="III-1017  @$tr(""52341"",""42315"",""AC,)("")"
 S ^NEXT="111^V3NEWI4,V3NEWI5^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A(2)="A(2)",B(2)="B(2)",C(2)="C(2)"
 D NEWEXC23
 D CHECK
 S ^VCORR="10010/11 1 1 0 10 1 11 1 aa(2)bc(2)dd(2)#11 1 10 1 10 1 0 0 aa(2)B(2)c(2)#"
 D ^VEXAMINE
 ;
111 S ^ABSN="31018",^ITEM="III-1018  @AA($O(AA(A)))"
 S ^NEXT="^V3NEWI5,V3NEWI6^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",A(2)="A(2)",B="B",B(2)="B(2)",C="C",C(2)="C(2)"
 D NEWEXC24,CHECK
 S ^VCORR="0110/11 1 11 1 10 1 11 1 aa(2)bB(2)c(2)dd(2)#11 1 11 1 11 1 11 1 AA(2)bB(2)CC(2)dd(2)#"
 D ^VEXAMINE
 ;
END W !!,"End of 118 --- V3NEWI4",!
 K  Q
 ;
NEWEXC21 ;
 N @"(A,B)"
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;000/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK QUIT
 ;
NEWEXC22 ;
 S ZZZZZZZZ("abcd","efg",1,2,3,4)="A,(B,C)"
 N @ZZZZZZZZ("abcd","efg",1,2,3,4)
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;011/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK Q
 ;
NEWEXC23 ;
 N @$tr("52341","42315","AC,)(")
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;10010/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK Q
 ;
NEWEXC24 ;
 S AA(0)=""
 S AA("DD")="(B,D)"
 NEW @AA($O(AA(A)))
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;0110/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK Q
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
