V3NEWN8 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"129---V3NEWN8: NEW -59-"
 ;
145 S ^ABSN="31052",^ITEM="III-1052  selective, selective, all      "
 S ^NEXT="146^V3NEWN8,V3NEWN9^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 S ^VV("D")="D"
 D NEW1,CHECK
 S ^VCORR="1 0 10 1 11 1 1 0 a3b(3)c3c(3)d3#11 1 11 1 11 1 10 1 aa(2)b@C(""AB"",2.4)c1c(2)d(2)#11 1 0 0 11 1 0 0 aa(2)c1c(2)#11 1 0 0 11 1 0 0 aa(2)c1c(2)#"
 D ^VEXAMINE K ^VV
 ;
146 S ^ABSN="31053",^ITEM="III-1053  selective, selective, selective"
 S ^NEXT="147^V3NEWN8,V3NEWN9^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 D NEW2,CHECK
 S ^VCORR="11 1 11 1 11 1 10 1 a3a(3)b3AAc(3)d(3)#1 0 11 1 11 1 0 0 ab3AAc(3)#11 1 11 1 11 1 0 0 A(""AB"")CB@A@(2.4)Ac(3)#11 1 10 0 11 0 0 0 A(""AB"")Cc1#"
 D ^VEXAMINE
 ;
147 S ^ABSN="31054",^ITEM="III-1054  selective, selective, exclusive"
 S ^NEXT="^V3NEWN9,V3NEWN10^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 D NEW3,CHECK
 S ^VCORR="1 0 0 0 10 1 0 0 a3c(3)#11 1 1 0 10 1 0 0 a2@C(""AB"",2.4)b2c(3)#11 1 11 1 11 1 0 0 a2@C(""AB"",2.4)BB(1)CC(1)#11 1 10 0 11 1 0 0 a2@C(""AB"",2.4)CC(1)#"
 D ^VEXAMINE
 ;
END W !!,"End of 129 --- V3NEWN8",!
 K  K ^VV Q
 ;
NEW1 ;
 S A="a1",B(2)="b(1)",C="c1",C(2)="c(1)"
 NEW E,F,G
 S A("AB",2.4)="@B(""AB"",2.4)",B("AB",2.4)="@C(""AB"",2.4)",C("AB",2.4)="@^VV(""D"")"
 D NEW1N,CHECK q
 ;
NEW1N NEW:.001 @A("AB",2.4)
 S A="a",A("AB",2.4)="a(2)",B="b",C("AB",2.4)="c(2)",D("AB",2.4)="d(2)"
 D NEW1M,CHECK k B Q
 ;
NEW1M NEW
 S A="a3",B("AB",2.4)="b(3)",C="c3",C("AB",2.4)="c(3)",D="d3"
 D CHECK K B,C Q
 ;
NEW2 ;
 S A="a1",B(2)="b(1)",C="c1",C(2)="c(1)"
 NEW B,D,C
 S A="A(""AB"")",A("AB",2.4)="C",B="B",B("AB",2.4)="@A@(2.4)"
 D NEW2N,CHECK q
 ;
NEW2N ;
 s C="A",C("AB",2.4)="C(""AB"",2.4)"
 IF $D(B)  N @@@B("AB",2.4),B ;A,B
 ELSE  K B
 S A="a",B="b",B("AB",2.4)="A",C("AB",2.4)="c(2)"
 D NEW2M D CHECK Q
 ;
NEW2M ;
 N @@("B(""A"_"B"")")@(2.4),D ;A,D
 S A="a3",A("AB",2.4)="a(3)",B="b3",C("AB",2.4)="c(3)",D("AB",2.4)="d(3)"
 D CHECK
 Q
 ;
NEW3 S A="a1",B(2)="b(1)",C="c1",C(2)="c(1)"
 NEW B,E,F,G
 S A="A",A("AB",2.4)="A(""AB"",2.4)"
 S B="B",B("AB",2.4)="B(1)"
 S C="C",C("AB",2.4)="C(1)"
 D NEW3N,CHECK q
 ;
NEW3N ;
 s ^VV("AB",2.4)="B",^VV("AB",0)="A"
 NEW C,@^(2.4) ;C,B
 S A="a2",A("AB",2.4)="@C(""AB"",2.4)",B="b2",C("AB",2.4)="B"
 s ^VV("AB",2.4)="B"
 D NEW3M,CHECK Q
 ;
NEW3M ;
 N @A("AB",2.4),@^(0) ;B,A
 S A="a3",B="b3",B("AB",2.4)="b(3)",C("AB",2.4)="c(3)",D="d3"
 k (C,A) D CHECK Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
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
 S ^VCOMP=^VCOMP_"#"
