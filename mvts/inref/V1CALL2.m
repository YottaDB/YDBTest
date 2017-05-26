V1CALL2 ;IW-KO-TS,V1CALL,MVTS V9.10;15/6/96;DO (CALL) COMMAND  -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"133---V1CALL2: DO command  ( call external routine )  -2-",!
 ;
178 W !!,"DO label+intexpr^routineref",!
 W !,"I-178  intexpr is positive integer"
 S ^ABSN="11675",^ITEM="I-178  intexpr is positive integer",^NEXT="179^V1CALL2,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 D 2+1^V1CALLE D %2345678+0002^V1CALLE,V1CALLE+08^V1CALLE
 S ^VCORR="3 Q 7 " D ^VEXAMINE
 ;
179 W !,"I-179  intexpr is zero"
 S ^ABSN="11676",^ITEM="I-179  intexpr is zero",^NEXT="180^V1CALL2,V1IE^VV1" D ^V1PRESET
 ;(test fixed in V9.1;7/10/95)
 S ^VCOMP=""
 DO ABCDEFGH+--"NUMBER"^V1CALLE
 S ^VCORR="ABCDEFGH " D ^VEXAMINE
 ;
180 W !,"I-180  intexpr is non-integer numlit"
 S ^ABSN="11677",^ITEM="I-180  intexpr is non-integer numlit",^NEXT="181^V1CALL2,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 D 012+3.99999^V1CALLE
 S ^VCORR="% " D ^VEXAMINE
 ;
181 W !,"I-181  intexpr contains binaryops"
 S ^ABSN="11678",^ITEM="I-181  intexpr contains binaryops",^NEXT="182^V1CALL2,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 D V1CALLE+7-11+12^V1CALLE
 S ^VCORR="7 " D ^VEXAMINE
 ;
182 W !,"I-182  intexpr contains a unaryop"
 S ^ABSN="11679",^ITEM="I-182  intexpr contains a unaryop",^NEXT="183^V1CALL2,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 D IF+'0^V1CALLE
 S ^VCORR="%0 " D ^VEXAMINE
 ;
183 W !,"I-183  intexpr is a function"
 S ^ABSN="11680",^ITEM="I-183  intexpr is a function",^NEXT="184^V1CALL2,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 D %2345678+$P("2,4,1,3^4",",",4)^V1CALLE
 S ^VCORR="%A1 " D ^VEXAMINE
 ;
184 W !,"I-184  intexpr is a gvn"
 S ^ABSN="11681",^ITEM="I-184  intexpr is a gvn",^NEXT="185^V1CALL2,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 S ^V1A=11 D 1+^V1A^V1CALLE
 S ^VCORR="AABBCC " D ^VEXAMINE
 ;
185 W !,"I-185  intexpr contains gvn as expratom"
 S ^ABSN="11682",^ITEM="I-185  intexpr contains gvn as expratom",^NEXT="834^V1CALL2,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 S ^V1A=11 D Z+-20+^V1A+^V1A^V1CALLE
 S ^VCORR="%2345678 " D ^VEXAMINE
 ;
834 W !,"I-834  Argument list ^routineref without postcondition"
 S ^ABSN="11683",^ITEM="I-834  Argument list ^routineref without postcondition",^NEXT="835^V1CALL2,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 D ^V1CALLE,^V1CALLE,^V1CALLE
 S ^VCORR="1 1 1 " D ^VEXAMINE
 ;
835 W !,"I-835  Argument list label^routineref without postcondition"
 S ^ABSN="11684",^ITEM="I-835  Argument list label^routineref without postcondition",^NEXT="836^V1CALL2,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 D AABBCC^V1CALLE,Z^V1CALLE,DO^V1CALLE,%0000000^V1CALLE
 S ^VCORR="AABBCC Z DO %0000000 " D ^VEXAMINE
 ;
836 W !,"I-836  Argument list label+intexpr^routineref without postcondition"
 S ^ABSN="11685",^ITEM="I-836  Argument list label+intexpr^routineref without postcondition",^NEXT="V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 D 012+3.999^V1CALLE,%0A1B2C3+3^V1CALLE,ABCDEFGH+--"04ENUMBER"^V1CALLE,^V1CALLE
 S ^VCORR="% 10 01 1 " D ^VEXAMINE
 ;
END W !!,"End of 133---V1CALL2",!
 K  K ^V1A Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
