V2VNIB ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;VARIABLE NAME INIDIRECTION -2-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"15---V2VNIB: Variable name indirection -2-",!
130 S ^ABSN="20142",^ITEM="II-130.1  local",^NEXT="1302^V2VNIB,V2VNIC^VV2" W !,^ITEM D ^V2PRESET
 K  S VCOMP="" S B="C(K)",K=1,C(1,"A")=2
 S:@B@("A")=2 D(1)="" S:@B@("A")=3 D(2)=""
 S VCOMP=VCOMP_$D(D(1))_$D(D(2))
 S ^VCOMP=VCOMP,^VCORR="10" D ^VEXAMINE
 ;
1302 S ^ABSN="20143",^ITEM="II-130.2  global",^NEXT="1303^V2VNIB,V2VNIC^VV2" D ^V2PRESET
 S VCOMP="" K ^VV S B="^VV",^VV("A")=2
 S:@B@("A")=2 ^VV(10)="" S:@B@("A")=3 ^VV(11)=""
 S VCOMP=VCOMP_$D(^VV(10))_$D(^VV(11))
 S ^VCOMP=VCOMP,^VCORR="10" D ^VEXAMINE
 ;
1303 S ^ABSN="20144",^ITEM="II-130.3  DO and GOTO command",^NEXT="131^V2VNIB,V2VNIC^VV2" D ^V2PRESET
 S VCOMP="" K ^VV
 S B="C(K)",C(1,2,3,4)=11,K=1,C(1,"A")=2,C(1)=3,I=4,C(1,9)="A"
 D:@B@("A")=2 EA:@B@(2,3,4)=11,EB:@B@(@B@(@B@(9)),@B,I)=11,EC:@B@(2,3,4)=10
 D:@B@("A")=3 EA:@B@(2,3,4)=11,EB:@B@(@B@(@B@(9)),@B,I)=11,EC:@B@(2,3,4)=10
 ;
 S B="^VV",^VV(1,2,3,4)=11,^VV("A")=2,^VV=3,I=4,^VV(9)="A"
 D:@B@("A")=2 EA:@B@(1,2,3,4)=11,EB:@B@(1,@B@(@B@(9)),@B,I)=11,EC:@B@(1,2,3,4)=10
 D:@B@("A")=3 EA:@B@(1,2,3,4)=11,EB:@B@(1,@B@(@B@(9)),@B,I)=11,EC:@B@(1,2,3,4)=10
 G:@B@("A")=2 G130:@B@(1,2,3,4)=11 S VCOMP=VCOMP_" ER GOTO 1 "
 S VCOMP=VCOMP_" ER GOTO 2 "
 ;
G130 S ^VCOMP=VCOMP,^VCORR="ABAB" D ^VEXAMINE
 ;
131 S ^ABSN="20145",^ITEM="II-131  Variable name indirection in expr to the right of the =",^NEXT="132^V2VNIB,V2VNIC^VV2" W !,^ITEM D ^V2PRESET
 K  S VCOMP=""
 S B="C(K)",C(1,2,3,4)=11,K=1,C(1,"A")=2,C(1)=3,I=4,C(1,9)="A"
 S:@B@(@B@(@B@(9)),@B,I)=11 @B@(1)=@B@(9),@B@(2)=@B@(@B@(9))
 S:@B@(@B@(@B@(9)),@B,I)=10 @B@(3)=@B@(9),@B@(4)=@B@(@B@(9)) ;local
 S VCOMP=VCOMP_"*"_$D(C(1,1))_"*"_$D(C(1,2))_"*"_$D(C(1,3))_"*"_$D(C(1,4))
 ;
 K ^VV S B="^VV",^VV(1,2,3,4)=11,^VV("A")=2,^VV=3,I=4,^VV(9)="A"
 S:@B@(1,@B@(@B@(9)),@B,I)=11 @B@(1)=@B@(9),@B@(2)=@B@(@B@(9)) ;global
 S:@B@(1,@B@(@B@(9)),@B,I)=10 @B@(3)=@B@(9),@B@(4)=@B@(@B@(9))
 S VCOMP=VCOMP_"*"_$D(^VV(1))_"*"_$D(^VV(2))_"*"_$D(^VV(3))_"*"_$D(^VV(4))
 S ^VCOMP=VCOMP,^VCORR="*1*11*0*0*11*1*0*0" D ^VEXAMINE
 ;
132 W !,"II-132  Value of indirection contains variable name indirection"
1321 S ^ABSN="20146",^ITEM="II-132.1  interpretation of indirection",^NEXT="1322^V2VNIB,V2VNIC^VV2" D ^V2PRESET
 K  S VCOMP=""
 S B="A(1)",C="@B@(1)" S A(1,1)=1 S VCOMP=VCOMP_@C
 S @C=2 S VCOMP=VCOMP_A(1,1)
 S A(1,1,1)=3 S VCOMP=VCOMP_@C@(1) S @C@(1)=4 S VCOMP=VCOMP_A(1,1,1)
 S B="A(2)",C="@B@(2)",D="@C",@D=5 S VCOMP=VCOMP_A(2,2)_@D
 S @D@(2)=6 S VCOMP=VCOMP_A(2,2,2)_@D@(2)
 S B="A(3)",C(3,3)="@B",D="C(3)",E="@@D@(3)",@E=7 S VCOMP=VCOMP_A(3)_@E
 S @E@(3)=8 S VCOMP=VCOMP_A(3,3)_@E@(3) S:@E@(3)=8 VCOMP=VCOMP_@E@(3)
 S ^VCOMP=VCOMP,^VCORR="1234556677888" D ^VEXAMINE
 ;
1322 S ^ABSN="20147",^ITEM="II-132.2  another interpretation of indirection",^NEXT="1323^V2VNIB,V2VNIC^VV2" D ^V2PRESET
 S VCOMP=""
 S G="@G1",G1="Z",Z="B",H1="H(1)",H="@@H1@(@G)@(""-"")",H(1,"B")="I(1)",I(1,"-")="C"
 S A="D(1,2,3,4,5)",B="@A@(""A"")",C="@B",D="@A@(@G)",E="@A@(@H)",F="@E@(1)=@B+@B"
 S @C=1,@D=@B,@E=@B+1,@F
 S VCOMP=VCOMP_@C_@D_@E_@E@(1)
 S VCOMP=VCOMP_D(1,2,3,4,5,"A")_D(1,2,3,4,5,"B")_D(1,2,3,4,5,"C")_D(1,2,3,4,5,"C",1)
 S ^VCOMP=VCOMP,^VCORR="11221122" D ^VEXAMINE
 ;
1323 S ^ABSN="20148",^ITEM="II-132.3  value of name indirection contains variable name indirection",^NEXT="V2VNIC^VV2" D ^V2PRESET
 S B="A(1)",A="@B@(1)",A(1,1)="@B@(2)",A(1,2)="@B@(3)",A(1,3)="@B@(4)",A(1,4)="#"
 S ^VCOMP=A_@A_@@A_@@@A_@@@@A,@@@@A="$",^VCOMP=^VCOMP_A_@A_@@A_@@@A_@@@@A
 S ^VCORR="@B@(1)@B@(2)@B@(3)@B@(4)#@B@(1)@B@(2)@B@(3)@B@(4)$" D ^VEXAMINE
 ;
END W !!,"End of 15---V2VNIB",!
 K  K ^VV Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
EA S VCOMP=VCOMP_"A" Q
EB S VCOMP=VCOMP_"B" Q
EC S VCOMP=VCOMP_"C" Q
