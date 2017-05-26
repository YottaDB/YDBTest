V2VNIC ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;VARIABLE NAME INIDIRECTION -3-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"16---V2VNIC: Variable name indirection -3-",!
133 W !,"II-133  Variable name indirection in expr"
 S ^ABSN="20149",^ITEM="II-133  Variable name indirection in expr",^NEXT="134^V2VNIC,V2NR^VV2" D ^V2PRESET
 S VCOMP="" K VV
 S A="VV",B="VV(1)",@A@(1)=0,@A@(1,2)=0 K @B@(2) S VCOMP=VCOMP_$D(@A@(1))_" "
 K ^VV,^V S ^V="^VV",@^V@(1)=0,^(1,2)=0 K ^(2) S VCOMP=VCOMP_$D(@^V@(1))_" "
 S A="ABC(1,2,3)",ABC(1,2,3,4,5)="ABCDEFGHIJKL",ABC(1,2,3,4)=0.1234,ABC(1,2,3,5)=3
 S @A@("@")=3,ABC(1,2,3,"-")=-0.11834
 S VCOMP=VCOMP_(@A@(5)+@A@(5))_" "
 S VCOMP=VCOMP_$E(@A@(4,5),1,@A@("@"))_" "_$E(@A@(4,5),4,@A@(5)+@A@(5))_" "
 S VCOMP=VCOMP_$F(@A@(4,5),$E(@A@(4,5),4,@A@(5)+@A@(5)),-1)_" "
 S VCOMP=VCOMP_$J(@A@(4),5,2)_$j(@A@("-"),6,2)_" "
 S ABC(1,2,3,"A")="1BC1B"
 S VCOMP=VCOMP_$L(@A@("A"))_$L(@A@("A"),"B")_$l(@A@("A"),"1B")_$L(@A@("A"),"1BC")_" "
 S VCOMP=VCOMP_$P(@A@(4,5),"E")_" "
 S VCOMP=VCOMP_$T(+@^V@(1))_" "
 ;
 S VCOMP=VCOMP_@A@("@")_@A@("A")_" "_(+@A@("@")+-+-+@A@("A"))_" "
 S @A@(1)="ABC^DEF^GHIJ^KLMN^OPQRS^",$P(@A@(1),"^",2,@A@("@"))="123^4567"
 S VCOMP=VCOMP_@A@(1)
 ;
 S ^VCOMP=VCOMP
 S ^VCORR="1 1 6 ABC DEF 7  0.12 -0.12 5332 ABCD V2VNIC 31BC1B 4 ABC^123^4567^KLMN^OPQRS^"
 D ^VEXAMINE
 ;
134 W !,"II-134  Multi-assignment of variable name indirection"
 S ^ABSN="20150",^ITEM="II-134  Multi-assignment of variable name indirection",^NEXT="135^V2VNIC,V2NR^VV2" D ^V2PRESET
 S VCOMP="" K A,B
 S A="B(1,1)",(@A@(1),@A@(2),@A@(3),@A@(4))=0 S VCOMP=VCOMP_B(1,1,1)_B(1,1,2)_B(1,1,3)_B(1,1,4)
 K ^VV S A="^VV(1,1)",(@A@(1),@A@(2),@A@(3),@A@(4))=1 S VCOMP=VCOMP_^VV(1,1,1)_^VV(1,1,2)_^VV(1,1,3)_^VV(1,1,4)
 S ^VCOMP=VCOMP,^VCORR="00001111" D ^VEXAMINE
 ;
135 W !,"II-135  Value of XECUTE argument contains variable name indirection"
 S ^ABSN="20151",^ITEM="II-135  Value of XECUTE argument contains variable name indirection",^NEXT="V2NR^VV2" D ^V2PRESET
 S V="" K A,B S B="A(1)"
 S A(1,1)="S V=V_2 X @B@(2) S V=V_8",A(1,2)="S V=V_3 X @B@(3),@B@(3) S V=V_7"
 S A(1,3)="S V=V_4 X @B@(4) S V=V_6",A(1,4)="S V=V_@B@(5)",A(1,5)=5
 S V=V_1 X @B@(1) S V=V_9 S ^VCOMP=V,^VCORR="123456456789" D ^VEXAMINE
 ;
END W !!,"End of 16---V2VNIC",!
 K  K ^VV,^V Q
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
