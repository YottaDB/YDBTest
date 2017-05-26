V3FN222 ;IW-KO-YS-TS,V3FN2,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"65---V3FN222: $FNUMBER(numexpr,fncodexpr)  -22-"
 ;
391 W !!,"numexpr is a strlit"
 S ^ABSN="30842",^ITEM="III-0842  ""09878978.78E2"""
 S ^NEXT="392^V3FN222,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN("09878978.78E2",",")
 S ^VCORR="987,897,878" D ^VEXAMINE
 ;
392 S ^ABSN="30843",^ITEM="III-0843  ""-0987x8978.78E2"""
 S ^NEXT="393^V3FN222,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN("-0987x8978.78E2","+")
 S ^VCORR="-987" D ^VEXAMINE
 ;
393 W !!,"numexpr is a lvn"
 ;
 S ^ABSN="30844",^ITEM="III-0844  lvn=VV"
 S ^NEXT="394^V3FN222,V3FN3^VV3" D ^V3PRESET
 S VV=-089.38740
 S ^VCOMP=$FN(VV,",P")
 S ^VCORR="(89.3874)" D ^VEXAMINE k VV
 ;
394 S ^ABSN="30845",^ITEM="III-0845  lvn=VV(VV)"
 S ^NEXT="395^V3FN222,V3FN3^VV3" D ^V3PRESET
 S VV=23.09,VV(23.090)="023186.4650"
 S ^VCOMP=$FN(VV(VV),"-,")
 S ^VCORR="23,186.465" D ^VEXAMINE K VV
 ;
 W !!,"numexpr is a gvn"
395 S ^ABSN="30846",^ITEM="III-0846  gvn=^VV"
 S ^NEXT="396^V3FN222,V3FN3^VV3" D ^V3PRESET
 S ^VV=-089.38740
 S ^VCOMP=$FN(^VV,",P")
 S ^VCORR="(89.3874)" D ^VEXAMINE K ^VV
 ;
396 S ^ABSN="30847",^ITEM="III-0847  gvn=^VV(VV)"
 S ^NEXT="397^V3FN222,V3FN3^VV3" D ^V3PRESET
 S VV=23.09,^VV(23.090)="023186.460"
 S ^VCOMP=$FN(^VV(VV),"-,")
 S ^VCORR="23,186.46" D ^VEXAMINE K ^VV
 ;
397 S ^ABSN="30848",^ITEM="III-0848  gvn=^(23)"
 S ^NEXT="398^V3FN222,V3FN3^VV3" D ^V3PRESET K ^VV
 S ^VV(3,4,23)=23,A=$D(^VV(3,4,2))
 S ^VCOMP=$FN(^(23),"P")
 S ^VCORR=" 23 " D ^VEXAMINE K ^VV
 ;
398 W !!,"numexpr contains unary operator"
 S ^ABSN="30849",^ITEM="III-0849  numexpr contains unary operator"
 S ^NEXT="399^V3FN222,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(-+-+-''-123,"T")
 S ^VCORR="1-" D ^VEXAMINE
 ;
399 W !!,"numexpr contains binary operator"
 S ^ABSN="30850",^ITEM="III-0850  numexpr contains binary operator"
 S ^NEXT="400^V3FN222,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(123#10+30-1*-1_12150,",")
 S ^VCORR="-3,212,150" D ^VEXAMINE
 ;
400 W !!,"numexpr has function"
 S ^ABSN="30851",^ITEM="III-0851  numexpr has function"
 S ^NEXT="401^V3FN222,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN($FN($j(8423.7049,5,2),"+"),",")
 S ^VCORR="8,423.7" D ^VEXAMINE
 ;
401 W !!,"numexpr contains indirection"
 S ^ABSN="30852",^ITEM="III-0852  numexpr contains indirection"
 S ^NEXT="402^V3FN222,V3FN3^VV3" D ^V3PRESET
 S A="B(12,0,9)",B(8)="C(2,00,""c"")",C(2,00,"c")="00"
 S B(12,0,9,"00")="+78.33763E2"
 S ^VCOMP=$FN(@A@(@B(8)),",T")
 S ^VCORR="7,833.763 " D ^VEXAMINE
 ;
402 W !!,"numexpr is expr"
 S ^ABSN="30853",^ITEM="III-0853  numexpr is expr"
 S ^NEXT="403^V3FN222,V3FN3^VV3" D ^V3PRESET I 1
 S A(9)="^VVB(8)",^VVB(8)="B(9)",B(9)="78909.30"
 S ^VCOMP=$FN(-$E(("0923"_"7DS8")*$T,3,+99)_@@A(9),"P,")
 S ^VCORR="(3,778,909.3)" D ^VEXAMINE K ^VVB
 ;
 ;
403 W !!,"fncodexpr is a lvn"
 S ^ABSN="30854",^ITEM="III-0854  fncodexpr is a lvn"
 S ^NEXT="404^V3FN222,V3FN3^VV3" D ^V3PRESET
 S VV(3,5,6,7,90)=-0.99993,VV(5)="-"
 S ^VCOMP=$FN(VV(3,5,6,7,90),VV(5))
 S ^VCORR=".99993" D ^VEXAMINE
 ;
404 W !!,"fncodexpr is a gvn"
 S ^ABSN="30855",^ITEM="III-0855  fncodexpr is a gvn"
 S ^NEXT="405^V3FN222,V3FN3^VV3" D ^V3PRESET
 S AB="B" K ^VVA
 S ^VVA(7,"B")="T+"
 S ^VCOMP=$FN(76484,^VVA(7,AB))
 S ^VCORR="76484+" D ^VEXAMINE K ^VVA
 ;
405 W !!,"fncodexpr contains binary operator"
 S ^ABSN="30856",^ITEM="III-0856  fncodexpr contains binary operator"
 S ^NEXT="406^V3FN222,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(78-938474,"+"_"T")
 S ^VCORR="938396-" D ^VEXAMINE
 ;
406 W !!,"fncodexpr has function"
 S ^ABSN="30857",^ITEM="III-0857  fncodexpr has function"
 S ^NEXT="407^V3FN222,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(12345678,$TR("AJDXPKEFYL","EXAJDPKFYLPAFDJ",",P"))
 S ^VCORR=" 12,345,678 " D ^VEXAMINE
 ;
407 W !!,"fncodexpr is a expr"
 S ^ABSN="30858",^ITEM="III-0858  fncodexpr is a expr"
 S ^NEXT="END^V3FN222,V3FN3^VV3" D ^V3PRESET
 K ^VV S ^VV("a","b","c")=""
 s A="^VV(@X1,@@X3)",X1="X2",X2="a",X3="X4",X4="X5",X5="b"
 s B="A"
 S ^VCOMP=$FN("-0.897000",@$Q(@@B))
 S ^VCORR="-.897" D ^VEXAMINE K ^VV
 ;
END W !!,"End of 65 --- V3FN222",!
 K  K ^VV Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
