V3NEWI6 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"120---V3NEWI6: NEW -50-"
 ;
116 S ^ABSN="31023",^ITEM="III-1023  (@""A"",@""B"",@""C"")"
 S ^NEXT="117^V3NEWI6,V3NEWI7^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 D NEWEXC31,CHECK
 S ^VCORR="000/11 1 1 0 10 1 11 1 aa(2)bc(2)dd(2)#11 1 1 0 10 1 0 0 aa(2)bc(2)#"
 D ^VEXAMINE
 ;
117 S ^ABSN="31024",^ITEM="III-1024  (@C,@A,@B)"
 S ^NEXT="118^V3NEWI6,V3NEWI7^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",B="B",C="C"
 D NEWEXC32,CHECK
 S ^VCORR="111/11 1 1 0 11 1 11 1 aa(2)bCc(2)dd(2)#11 1 1 0 11 1 0 0 aa(2)bCc(2)#"
 D ^VEXAMINE
 ;
118 S ^ABSN="31025",^ITEM="III-1025  (@$E(""ABCDEF"",3),@$C(65),@$TR(123.456,0.12345678,""D""))"
 S ^NEXT="119^V3NEWI6,V3NEWI7^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A(2)="A(2)",B(2)="B(2)",C(2)="C(2)"
 D NEWEXC33,CHECK
 S ^VCORR="10010/11 1 1 0 10 1 11 1 aa(2)bc(2)dd(2)#11 1 10 1 10 1 11 1 aa(2)B(2)c(2)dd(2)#"
 D ^VEXAMINE
 ;
119 S ^ABSN="31026",^ITEM="III-1026  @""(@BB,@A,@CC(2))"""
 S ^NEXT="^V3NEWI7,V3NEWN1^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",A(2)="A(2)",B="B",B(2)="B(2)",C="C",C(2)="C(2)"
 D NEWEXC34,CHECK
 S ^VCOMP=^VCOMP_$D(BB)_" "_$D(CC(2))_" "
 I $D(BB)#10=1    S ^VCOMP=^VCOMP_BB
 I $D(CC(2))#10=1 S ^VCOMP=^VCOMP_CC(2)
 S ^VCORR="111111/11 1 11 1 11 1 11 1 aa(2)bB(2)Cc(2)dd(2)#0 0 11 1 11 1 11 1 0 0 aa(2)bB(2)Cc(2)#1 1 B@CC(1)"
 D ^VEXAMINE
 ;
END W !!,"End of 120 --- V3NEWI6",!
 K  Q
 ;
NEWEXC31 ;
 N (@"A",@"B",@"C")
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;000/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK Q
 ;
NEWEXC32 ;
 N (@C,@A,@B)
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;111/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK Q
 ;
NEWEXC33 ;
 NEW (@$E("ABCDEF",3),@$C(65),@$TR(123.456,0.12345678,"D"))
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;10010/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK Q
 ;
NEWEXC34 ;
 S BB="B",CC(2)="@CC(1)",CC(1)="C"
 NEW @"(@BB,@A,@CC(2))"
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;111111/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK
 S ^VCOMP=^VCOMP_$D(BB)_" "_$D(CC(2))_" "
 I $D(BB)#10=1    S ^VCOMP=^VCOMP_BB
 I $D(CC(2))#10=1 S ^VCOMP=^VCOMP_CC(2)
 Q
 ;
CHECK S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "
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
 S ^VCOMP=^VCOMP_"#" Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
