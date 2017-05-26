V3FN220 ;IW-KO-YS-TS,V3FN2,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"63---V3FN220: $FNUMBER(numexpr,fncodexpr)  -20-"
362 W !!,"fncodexpr is a ""T+,-""" ;------
 ;
 S ^ABSN="30813",^ITEM="III-0813  fncodexpr is a ""T+,-"""
 S ^NEXT="363^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(0.0002004E+10,"T+,-")
 S ^VCORR="2,004,000+" D ^VEXAMINE
 ;
363 W !!,"fncodexpr is a "",T+-""" ;------
 ;
 S ^ABSN="30814",^ITEM="III-0814  fncodexpr is a "",T+-"""
 S ^NEXT="364^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(98765432E-10,",T+-")
 S ^VCORR=".0098765432+" D ^VEXAMINE
 ;
364 W !!,"fncodexpr is a "",T-+""" ;------
 ;
 S ^ABSN="30815",^ITEM="III-0815  fncodexpr is a "",T-+"""
 ;changed correct value 20/1/94
 S ^NEXT="365^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(-1,",T-+")
 S ^VCORR="1 " D ^VEXAMINE
 ;
365 W !!,"fncodexpr is a "",-+T""" ;------
 ;
 S ^ABSN="30816",^ITEM="III-0816  fncodexpr is a "",-+T"""
 S ^NEXT="366^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(0020.00000,",-+T")
 S ^VCORR="20+" D ^VEXAMINE
 ;
366 W !!,"fncodexpr is a "",-T+""" ;------
 ;
 S ^ABSN="30817",^ITEM="III-0817  fncodexpr is a "",-T+"""
 S ^NEXT="367^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(-00020.00000,",-T+")
 S ^VCORR="20 " D ^VEXAMINE
 ;
367 W !!,"fncodexpr is a "",+-T""" ;------
 ;
 S ^ABSN="30818",^ITEM="III-0818  fncodexpr is a "",+-T"""
 S ^NEXT="368^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(31267,",+-T")
 S ^VCORR="31,267+" D ^VEXAMINE
 ;
368 W !!,"fncodexpr is a "",+T-""" ;------
 ;
 S ^ABSN="30819",^ITEM="III-0819  fncodexpr is a "",+T-"""
 S ^NEXT="369^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(-31267,",+T-")
 S ^VCORR="31,267 " D ^VEXAMINE
 ;
369 W !!,"fncodexpr is a ""+T,-""" ;------
 ;
 S ^ABSN="30820",^ITEM="III-0820  fncodexpr is a ""+T,-"""
 S ^NEXT="370^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(000000000000000000000000262999219,"+T,-")
 S ^VCORR="262,999,219+" D ^VEXAMINE
 ;
370 W !!,"fncodexpr is a ""+T-,""" ;------
 ;
 S ^ABSN="30821",^ITEM="III-0821  fncodexpr is a ""+T-,"""
 S ^NEXT="371^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(-000000000000000000000000262999219,"+T-,")
 S ^VCORR="262,999,219 " D ^VEXAMINE
 ;
371 W !!,"fncodexpr is a ""+-,T""" ;------
 ;
 S ^ABSN="30822",^ITEM="III-0822  fncodexpr is a ""+-,T"""
 S ^NEXT="372^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(000.000789200,"+-,T")
 S ^VCORR=".0007892+" D ^VEXAMINE
 ;
372 W !!,"fncodexpr is a ""+-T,""" ;------
 ;
 S ^ABSN="30823",^ITEM="III-0823  fncodexpr is a ""+-T,"""
 S ^NEXT="373^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(-000.000789200,"+-T,")
 S ^VCORR=".0007892 " D ^VEXAMINE
 ;
373 W !!,"fncodexpr is a ""+,-T""" ;------
 ;
 S ^ABSN="30824",^ITEM="III-0824  fncodexpr is a ""+,-T"""
 S ^NEXT="374^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(00670.00789200,"+,-T")
 S ^VCORR="670.007892+" D ^VEXAMINE
 ;
374 W !!,"fncodexpr is a ""+,T-""" ;------
 ;
 S ^ABSN="30825",^ITEM="III-0825  fncodexpr is a ""+,T-"""
 S ^NEXT="375^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(-00670.00789200,"+,T-")
 S ^VCORR="670.007892 " D ^VEXAMINE
 ;
375 W !!,"fncodexpr is a ""-T,+""" ;------
 ;
 S ^ABSN="30826",^ITEM="III-0826  fncodexpr is a ""-T,+"""
 S ^NEXT="376^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(--981000000000,"-T,+")
 S ^VCORR="981,000,000,000+" D ^VEXAMINE
 ;
376 W !!,"fncodexpr is a ""-T+,""" ;------
 ;
 S ^ABSN="30827",^ITEM="III-0827  fncodexpr is a ""-T+,"""
 S ^NEXT="377^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(-981000000000,"-T+,")
 S ^VCORR="981,000,000,000 " D ^VEXAMINE
 ;
377 W !!,"fncodexpr is a ""-+,T""" ;------
 ;
 S ^ABSN="30828",^ITEM="III-0828  fncodexpr is a ""-+,T"""
 S ^NEXT="378^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(1E25,"-+,T")
 S ^VCORR="10,000,000,000,000,000,000,000,000+" D ^VEXAMINE
 ;
378 W !!,"fncodexpr is a ""-+T,""" ;------
 ;
 S ^ABSN="30829",^ITEM="III-0829  fncodexpr is a ""-+T,"""
 S ^NEXT="379^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(-1E25,"-+T,")
 S ^VCORR="10,000,000,000,000,000,000,000,000 " D ^VEXAMINE
 ;
379 W !!,"fncodexpr is a ""-,+T""" ;------
 ;
 S ^ABSN="30830",^ITEM="III-0830  fncodexpr is a ""-,+T"""
 S ^NEXT="380^V3FN220,V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(1E-25,"-,+T")
 S ^VCORR=".0000000000000000000000001+" D ^VEXAMINE
 ;
380 W !!,"fncodexpr is a ""-,T+""" ;------
 ;
 S ^ABSN="30831",^ITEM="III-0831  fncodexpr is a ""-,T+"""
 S ^NEXT="V3FN221^V3FN2,V3FN3^VV3" D ^V3PRESET
 S ^VCOMP=$FN(-1E-25,"-,T+")
 S ^VCORR=".0000000000000000000000001 " D ^VEXAMINE
 ;
END W !!,"End of 63 --- V3FN220",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
