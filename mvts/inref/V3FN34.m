V3FN34 ;IW-KO-YS-TS,V3FN3,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"69---V3FN34: $FNUMBER(numexpr,fncodexpr,intexpr) -4-"
 ;
 W !!,"numexpr is a strlit"
35 S ^ABSN="30893",^ITEM="III-0893  ""09878979.78E-2"""
 S ^NEXT="36^V3FN34,V3FN35^V3FN3,V3NEW^VV3" D ^V3PRESET
 S ^VCOMP=$FN("09878979.78E-2",",","2")
 S ^VCORR="98,789.80" D ^VEXAMINE
 ;
36 S ^ABSN="30894",^ITEM="III-0894  ""-0987,8978.78E2"""
 S ^NEXT="37^V3FN34,V3FN35^V3FN3,V3NEW^VV3" D ^V3PRESET
 S ABC=4
 S ^VCOMP=$FN("-0987,8978.78E2","+",+ABC)
 S ^VCORR="-987.0000" D ^VEXAMINE K ABC
 ;
37 W !!,"numexpr is a lvn"
 ;
 S ^ABSN="30895",^ITEM="III-0895  numexpr is a lvn"
 S ^NEXT="38^V3FN34,V3FN35^V3FN3,V3NEW^VV3" D ^V3PRESET
 S A("abc")=-045.380905
 S ^VCOMP=$FN(A("abc"),",P",4)
 S ^VCORR="(45.3809)" D ^VEXAMINE k VV
 ;
38 W !!,"numexpr is a gvn"
 S ^ABSN="30896",^ITEM="III-0896  ^VV(""abc"",VV,0)"
 S ^NEXT="39^V3FN34,V3FN35^V3FN3,V3NEW^VV3" D ^V3PRESET K ^VV
 S VV=23.09,^VV("abc",23.090,0)="03.245680,20E-3"
 S ^VCOMP=$FN(^VV("abc",VV,0),"-+",--1.66)
 S ^VCORR="+3.2" D ^VEXAMINE K ^VV
 ;
39 S ^ABSN="30897",^ITEM="III-0897  gvn=^(""x"",""y"")"
 S ^NEXT="40^V3FN34,V3FN35^V3FN3,V3NEW^VV3" D ^V3PRESET K ^VV
 S ^VV(3,"a","x","y")=00.230,A=$D(^VV(3,"a","u"))
 S ^VCOMP=$FN(^("x","y"),"",3)
 S ^VCORR="0.230" D ^VEXAMINE K ^VV
 ;
40 W !!,"numexpr contains unary operator"
 S ^ABSN="30898",^ITEM="III-0898  numexpr contains unary operator"
 S ^NEXT="41^V3FN34,V3FN35^V3FN3,V3NEW^VV3" D ^V3PRESET
 S ^VCOMP=$FN(-+-+-''-123,"T",6)
 S ^VCORR="1.000000-" D ^VEXAMINE
 ;
41 W !!,"numexpr contains binary operator"
 S ^ABSN="30899",^ITEM="III-0899  numexpr contains binary operator"
 S ^NEXT="42^V3FN34,V3FN35^V3FN3,V3NEW^VV3" D ^V3PRESET
 S ^VCOMP=$FN(123#10+30-1*-1_12150*1E-5,",",2)
 S ^VCORR="-32.12" D ^VEXAMINE
 ;
42 W !!,"numexpr has function"
 S ^ABSN="30900",^ITEM="III-0900  numexpr has function"
 S ^NEXT="43^V3FN34,V3FN35^V3FN3,V3NEW^VV3" D ^V3PRESET
 S ^VCOMP=$FN($FN($j(8423.7049,1),"+"),",T+",00000000000000000000000000000003)
 S ^VCORR="8,423.705+" D ^VEXAMINE
 ;
43 W !!,"numexpr contains indirection"
 S ^ABSN="30901",^ITEM="III-0901  numexpr contains indirection"
 S ^NEXT="44^V3FN34,V3FN35^V3FN3,V3NEW^VV3" D ^V3PRESET
 S A="B(12,0,9)",B(8)="C(2,00,""c"")",C(2,00,"c")="00"
 S B(12,0,9,"00")="+78.33763E2"
 S ^VCOMP=$FN(@A@(@B(8)),",T",000000000000000000000000.00000000000000000000000)
 S ^VCORR="7,834 " D ^VEXAMINE
 ;
44 W !!,"numexpr is expr"
 S ^ABSN="30902",^ITEM="III-0902  numexpr is expr"
 S ^NEXT="V3FN35^V3FN3,V3NEW^VV3" D ^V3PRESET I 1
 S A(9)="^VVB(8)",^VVB(8)="B(9)",B(9)="78909.30"
 S ^VCOMP=$FN(-$E(("0923"_"7DS8")*$T,3,+99)_@@A(9),"P,",3)
 S ^VCORR="(3,778,909.300)" D ^VEXAMINE K ^VVB
 ;
END W !!,"End of 69 --- V3FN34",!
 K  K ^VV,^VVB Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
