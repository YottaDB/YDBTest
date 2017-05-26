V3FN33 ;IW-KO-YS-TS,V3FN3,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"68---V3FN33: $FNUMBER(numexpr,fncodexpr,intexpr) -3-"
 ;
 W !!,"intexpr is a strlit"
25 S ^ABSN="30883",^ITEM="III-0883  ""2"""
 S ^NEXT="26^V3FN33,V3FN34^V3FN3,V3NEW^VV3" D ^V3PRESET
 S ^VCOMP=$FNUMBER(09878979.78E-2,",","2")
 S ^VCORR="98,789.80" D ^VEXAMINE
 ;
26 S ^ABSN="30884",^ITEM="III-0884  ""000004"""
 S ^NEXT="27^V3FN33,V3FN34^V3FN3,V3NEW^VV3" D ^V3PRESET
 S ^VCOMP=$FN(-"0987$8978.78E2","+","000004")
 S ^VCORR="-987.0000" D ^VEXAMINE
 ;
27 W !!,"intexpr is a lvn"
 S ^ABSN="30885",^ITEM="III-0885  intexpr is a lvn"
 S ^NEXT="28^V3FN33,V3FN34^V3FN3,V3NEW^VV3" D ^V3PRESET
 S A("abc")=4.00
 S ^VCOMP=$FNumber(-045.380905,",P",A("abc"))
 S ^VCORR="(45.3809)" D ^VEXAMINE k VV
 ;
28 W !!,"intexpr is a gvn"
 S ^ABSN="30886",^ITEM="III-0886  ^VV(""abc"",VV,0)"
 S ^NEXT="29^V3FN33,V3FN34^V3FN3,V3NEW^VV3" D ^V3PRESET K ^VV
 S VV=23.09,^VV("abc",23.090,0)=--1.66
 S ^VCOMP=$fn(003245.68020E-3,"-+",^VV("abc",VV,0))
 S ^VCORR="+3.2" D ^VEXAMINE K ^VV
 ;
29 S ^ABSN="30887",^ITEM="III-0887  gvn=^(""x"",""y"")"
 S ^NEXT="30^V3FN33,V3FN34^V3FN3,V3NEW^VV3" D ^V3PRESET K ^VV
 S ^VV(3,"a","x","y")=3,A=$D(^VV(3,"a","u"))
 S ^VCOMP=$FN(00.230,"",^("x","y"))
 S ^VCORR="0.230" D ^VEXAMINE K ^VV
 ;
30 W !!,"intexpr contains unary operator"
 S ^ABSN="30888",^ITEM="III-0888  intexpr contains unary operator"
 S ^NEXT="31^V3FN33,V3FN34^V3FN3,V3NEW^VV3" D ^V3PRESET
 S ^VCOMP=$FN(--8945632E-2,"T",+-+-''-123)
 S ^VCORR="89456.3 " D ^VEXAMINE
 ;
31 W !!,"intexpr contains binary operator"
 S ^ABSN="30889",^ITEM="III-0889  intexpr contains binary operator"
 S ^NEXT="32^V3FN33,V3FN34^V3FN3,V3NEW^VV3" D ^V3PRESET
 S ^VCOMP=$FN(12345E-5,",",123#10+30-1*-1_12150*-1E-6)
 S ^VCORR="0.123" D ^VEXAMINE
 ;
32 W !!,"intexpr has function"
 S ^ABSN="30890",^ITEM="III-0890  intexpr has function"
 S ^NEXT="33^V3FN33,V3FN34^V3FN3,V3NEW^VV3" D ^V3PRESET
 S ^VCOMP=$FN(8423.7049,",T+",$l("ABCDEBF","B"))
 S ^VCORR="8,423.705+" D ^VEXAMINE
 ;
33 W !!,"intexpr contains indirection"
 S ^ABSN="30891",^ITEM="III-0891  intexpr contains indirection"
 S ^NEXT="34^V3FN33,V3FN34^V3FN3,V3NEW^VV3" D ^V3PRESET
 S A="B(12,0,9)",B(8)="C(2,00,""c"")",C(2,00,"c")="00"
 S B(12,0,9,"00")="+78.33763E-1"
 S ^VCOMP=$FN(-C(2,00,"c"),",T",@A@(@B(8)))
 S ^VCORR="0.0000000 " D ^VEXAMINE
 ;
34 W !!,"intexpr is expr"
 S ^ABSN="30892",^ITEM="III-0892  intexpr is expr"
 S ^NEXT="V3FN34^V3FN3,V3NEW^VV3" D ^V3PRESET I 1
 S A(9)="^VVB(8)",^VVB(8)="B(9)",B(9)="78909.30"
 S ^VCOMP=$FN(-000.2000020,"P,",$FN(-$E(("0923"_"7DS8")*$T,3,+99)_@@A(9),"-,"))
 S ^VCORR="(0.200)" D ^VEXAMINE K ^VVB
 ;
END W !!,"End of 68 --- V3FN33",!
 K  K ^VV,^VVB Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
