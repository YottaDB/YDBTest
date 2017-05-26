V3NEWO2 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"96---V3NEWO2: NEW -26-"
 ;
51 S ^ABSN="30958",^ITEM="III-0958  $D(lvn)=10"
 S ^NEXT="52^V3NEWO2,V3NEWP^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A(2)="A(2)",B(2)="B(2)",C(2)="C(2)",C(3)="C(3)",C(9)="C(9)"
 S A(1)="A(1)",A("@")="@"
 D NEWO3
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;10 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;10 1 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;10 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;0 0 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;A(2)
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;B(2)
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;
 S Q="" F K=1:1 S Q=$O(A(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;12@
 S Q="" F K=1:1 S Q=$O(B(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;2
 S Q="" F K=1:1 S Q=$O(C(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;239
 S Q="" F K=1:1 S Q=$O(D(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;
 S ^VCORR="0010/11 1 1 0 10 1 0 0 aa(2)bc(2)2239#10 1 10 1 10 1 0 0 A(2)B(2)c(2)12@2239"
 D ^VEXAMINE
 ;
52 S ^ABSN="30959",^ITEM="III-0959  $D(lvn)=11"
 S ^NEXT="^V3NEWP,V3NEWX^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",A(2)="A(2)",B="B",B(2)="B(2)",C="C",C(2)="C(2)"
 S C(3)="C(3)",C(9)="C(9)",A(1)="A(1)",A("@")="@"
 D NEWO4
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;0 0 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;A
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;A(2)
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;B
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;B(2)
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;C
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;C(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;
 S Q="" F K=1:1 S Q=$O(A(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;12@
 S Q="" F K=1:1 S Q=$O(B(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;2
 S Q="" F K=1:1 S Q=$O(C(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;239
 S Q="" F K=1:1 S Q=$O(D(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;
 S ^VCORR="000/11 1 1 0 10 1 0 0 aa(2)bc(2)22#11 1 11 1 11 1 0 0 AA(2)BB(2)CC(2)12@2239"
 D ^VEXAMINE
 ;
END W !!,"End of 96 --- V3NEWO2",!
 K  Q
 ;
NEWO3 ;
 NEW (C)
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;0010/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)"
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;1 0 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;10 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;0 0 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;a
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;a(2)
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;b
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;
 S Q="" F K=1:1 S Q=$O(A(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;2
 S Q="" F K=1:1 S Q=$O(B(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;
 S Q="" F K=1:1 S Q=$O(C(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;239
 S Q="" F K=1:1 S Q=$O(D(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;
 S ^VCOMP=^VCOMP_"#"                      ;#
 QUIT
 ;
NEWO4 ;
 NEW (D)
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;000/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)"
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;1 0 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;10 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;0 0 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;a
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;a(2)
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;b
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;
 S Q="" F K=1:1 S Q=$O(A(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;2
 S Q="" F K=1:1 S Q=$O(B(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;
 S Q="" F K=1:1 S Q=$O(C(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;2
 S Q="" F K=1:1 S Q=$O(D(Q)) Q:Q=""  S ^VCOMP=^VCOMP_Q ;
 S ^VCOMP=^VCOMP_"#"                      ;#
 QUIT
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
