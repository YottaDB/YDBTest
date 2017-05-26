V1CALL1 ;IW-KO-TS,V1CALL,MVTS V9.10;15/6/96;DO (CALL) COMMAND  -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"132---V1CALL1: DO command  ( call external routine )  -1-",!
172 W !,"I-172  Argument list"
 S ^ABSN="11669",^ITEM="I-172  Argument list",^NEXT="173^V1CALL1,V1CALL2^V1CALL,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 DO 1^V1CALLE,2^V1CALLE,IF^V1CALLE
 S ^VCORR="1 2 IF " D ^VEXAMINE
 ;
173 W !,"I-173  ^routineref"
 S ^ABSN="11670",^ITEM="I-173  ^routineref",^NEXT="174^V1CALL1,V1CALL2^V1CALL,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 DO ^V1CALLE S ^VCOMP=^VCOMP_"CONTI"
 S ^VCORR="1 CONTI" D ^VEXAMINE
 ;
174 W !!,"DO label^routineref",!
 W !,"I-174  label^routineref  label is alphas"
 S ^ABSN="11671",^ITEM="I-174  label^routineref  label is alphas",^NEXT="175^V1CALL1,V1CALL2^V1CALL,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 D AABBCC^V1CALLE D Z^V1CALLE,DO^V1CALLE
 S ^VCORR="AABBCC Z DO " D ^VEXAMINE
 ;
175 W !,"I-175  label^routineref  label is a intlit"
 S ^ABSN="11672",^ITEM="I-175  label^routineref  label is a intlit",^NEXT="176^V1CALL1,V1CALL2^V1CALL,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 D 2^V1CALLE D 012^V1CALLE,0^V1CALLE
 S ^VCORR="2 012 0 " D ^VEXAMINE
 ;
176 W !,"I-176  label^routineref  label is % and alphas"
 S ^ABSN="11673",^ITEM="I-176  label^routineref  label is % and alphas",^NEXT="177^V1CALL1,V1CALL2^V1CALL,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 D %ABC^V1CALLE DO %^V1CALLE
 S ^VCORR="%ABC % " D ^VEXAMINE
 ;
177 W !,"I-177  label^routineref  label is % and digits"
 S ^ABSN="11674",^ITEM="I-177  label^routineref  label is % and digits",^NEXT="V1CALL2^V1CALL,V1IE^VV1" D ^V1PRESET
 S ^VCOMP=""
 D %0000000^V1CALLE,%2345678^V1CALLE
 S ^VCORR="%0000000 %2345678 " D ^VEXAMINE
 ;
END W !!,"End of 132---V1CALL1",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
