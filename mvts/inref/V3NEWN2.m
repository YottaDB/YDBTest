V3NEWN2 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"123---V3NEWN2: NEW -53-"
 ;
127 S ^ABSN="31034",^ITEM="III-1034  selective, all      "
 S ^NEXT="128^V3NEWN2,V3NEWN3^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 S ^VV("D")="D"
 S A("AB",2.4)="@B(""AB"",2.4)",B("AB",2.4)="@C(""AB"",2.4)",C("AB",2.4)="@^VV(""D"")"
 D NEW1,CHECK
 S ^VCORR="10 1 10 1 10 1 0 0 @B(""AB"",2.4)@C(""AB"",2.4)@^VV(""D"")#11 1 11 1 10 1 10 1 aa(2)b@C(""AB"",2.4)c(2)d(2)#0 0 0 0 0 0 0 0 #1 0 10 1 11 1 1 0 a3b(3)c3c(3)d3#11 1 11 1 10 1 10 1 aa(2)b@C(""AB"",2.4)c(2)d(2)#11 1 0 0 10 1 0 0 aa(2)c(2)#"
 D ^VEXAMINE K ^VV
 ;
128 S ^ABSN="31035",^ITEM="III-1035  selective, selective"
 S ^NEXT="129^V3NEWN2,V3NEWN3^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 S A="A(""AB"")",A("AB",2.4)="C",B="B",B("AB",2.4)="@A@(2.4)"
 D NEW2,CHECK
 S ^VCORR="0 0 0 0 11 1 0 0 AC(""AB"",2.4)#1 0 11 1 11 1 0 0 abAAc(2)#0 0 11 1 11 1 0 0 bAAc(2)#11 1 11 1 11 1 10 1 a3a(3)b3AAc(3)d(3)#1 0 11 1 11 1 0 0 ab3AAc(3)#11 1 11 1 11 1 0 0 A(""AB"")CB@A@(2.4)Ac(3)#"
 D ^VEXAMINE
 ;
129 S ^ABSN="31036",^ITEM="III-1036  selective, exclusive"
 S ^NEXT="^V3NEWN3,V3NEWN4^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 D NEW3,CHECK
 S ^VCORR="11 1 0 0 0 0 0 0 AA(""AB"",2.4)#11 1 1 0 10 1 0 0 a2@C(""AB"",2.4)b2B#0 0 0 0 10 1 0 0 B#1 0 11 1 10 1 1 0 a3b3b(3)c(3)d3#1 0 0 0 10 1 0 0 a3c(3)#11 1 1 0 10 1 0 0 a2@C(""AB"",2.4)b2c(3)#11 1 11 1 11 1 0 0 a2@C(""AB"",2.4)BB(1)CC(1)#"
 D ^VEXAMINE
 ;
END W !!,"End of 123 --- V3NEWN2",!
 K  K ^VV Q
 ;
NEW1 NEW:.001 @A("AB",2.4)
 D CHECK
 S A="a",A("AB",2.4)="a(2)",B="b",C("AB",2.4)="c(2)",D("AB",2.4)="d(2)"
 D CHECK,NEW1N,CHECK k B Q
 ;
NEW1N NEW
 D CHECK S A="a3",B("AB",2.4)="b(3)",C="c3",C("AB",2.4)="c(3)",D="d3"
 D CHECK K B,C Q
 ;
NEW2 ;
 s C="A",C("AB",2.4)="C(""AB"",2.4)"
 IF $D(B)  N @@@B("AB",2.4),B ;A,B
 ELSE  K B
 D CHECK
 S A="a",B="b",B("AB",2.4)="A",C("AB",2.4)="c(2)"
 D CHECK D NEW2N D CHECK Q
 ;
NEW2N ;
 N @@("B(""A"_"B"")")@(2.4),D ;A,D
 D CHECK
 S A="a3",A("AB",2.4)="a(3)",B="b3",C("AB",2.4)="c(3)",D("AB",2.4)="d(3)"
 D CHECK
 Q
 ;
NEW3 ;
 S A="A",A("AB",2.4)="A(""AB"",2.4)"
 S B="B",B("AB",2.4)="B(1)"
 S C="C",C("AB",2.4)="C(1)"
 s ^VV("AB",2.4)="B",^VV("AB",0)="A"
 NEW C,@^(2.4) ;C,B
 D CHECK
 S A="a2",A("AB",2.4)="@C(""AB"",2.4)",B="b2",C("AB",2.4)="B"
 D CHECK
 s ^VV("AB",2.4)="B"
 D NEW3N,CHECK Q
 ;
NEW3N ;
 N @A("AB",2.4),@^(0) ;B,A
 D CHECK
 S A="a3",B="b3",B("AB",2.4)="b(3)",C("AB",2.4)="c(3)",D="d3"
 D CHECK k (C,A) D CHECK Q
 ;
CHECK ;
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A("AB",2.4))_" "
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B("AB",2.4))_" "
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C("AB",2.4))_" "
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D("AB",2.4))_" "
 I $D(A)#10=1           S ^VCOMP=^VCOMP_A
 I $D(A("AB",2.4))#10=1 S ^VCOMP=^VCOMP_A("AB",2.4)
 I $D(B)#10=1           S ^VCOMP=^VCOMP_B
 I $D(B("AB",2.4))#10=1 S ^VCOMP=^VCOMP_B("AB",2.4)
 I $D(C)#10=1           S ^VCOMP=^VCOMP_C
 I $D(C("AB",2.4))#10=1 S ^VCOMP=^VCOMP_C("AB",2.4)
 I $D(D)#10=1           S ^VCOMP=^VCOMP_D
 I $D(D("AB",2.4))#10=1 S ^VCOMP=^VCOMP_D("AB",2.4)
 S ^VCOMP=^VCOMP_"#" Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
