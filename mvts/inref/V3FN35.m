V3FN35 ;IW-KO-YS-TS,V3FN3,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"70---V3FN35: $FNUMBER(numexpr,fncodexpr,intexpr) -5-"
 ;
45 W !!,"fncodexpr is a lvn"
 S ^ABSN="30903",^ITEM="III-0903  fncodexpr is a lvn"
 S ^NEXT="46^V3FN35,V3NEW^VV3" D ^V3PRESET
 S VV(3,5,6,7,90)=-0.99993,VV(5)="-"
 S ^VCOMP=$FN(VV(3,5,6,7,90),VV(5),$F(VV(3,5,6,7,90),"."))
 S ^VCORR="1.000" D ^VEXAMINE K VV
 ;
46 W !!,"fncodexpr is a gvn"
 S ^ABSN="30904",^ITEM="III-0904  fncodexpr is a gvn"
 S ^NEXT="47^V3FN35,V3NEW^VV3" D ^V3PRESET
 S AB="B" K ^VVA
 S ^VVA(7,"B")="T+"
 S ^VCOMP=$FN(76484,^VVA(7,AB),$D(^VVA(7,"A")))
 S ^VCORR="76484+" D ^VEXAMINE K AB K ^VVA
 ;
47 W !!,"fncodexpr contains binary operator"
 S ^ABSN="30905",^ITEM="III-0905  "
 S ^NEXT="48^V3FN35,V3NEW^VV3" D ^V3PRESET
 S ^VCOMP=$FN(78-938474,"+"_"T",6-4)
 S ^VCORR="938396.00-" D ^VEXAMINE
 ;
48 W !!,"fncodexpr has function"
 S ^ABSN="30906",^ITEM="III-0906  fncodexpr has function"
 S ^NEXT="49^V3FN35,V3NEW^VV3" D ^V3PRESET
 S ^VCOMP=$FN(12345678,$TR("AJDX,PKEF,YL","EXAJDPKFYLPAFDJ","P"),88/44)
 S ^VCORR=" 12,345,678.00 " D ^VEXAMINE
 ;
49 W !!,"fncodexpr is a expr"
 S ^ABSN="30907",^ITEM="III-0907  fncodexpr is a expr"
 S ^NEXT="END^V3FN35,V3NEW^VV3" D ^V3PRESET
 K ^VV S ^VV("a","b","c")=""
 s A="^VV(@X1,@@X3)",X1="X2",X2="a",X3="X4",X4="X5",X5="b"
 s B="A"
 S ^VCOMP=$FN("-0.897000",@$Q(@@B),X2)
 S ^VCORR="-1" D ^VEXAMINE K ^VV
 ;
END W !!,"End of 70 --- V3FN35",!
 K  K ^VV,^VVA Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
