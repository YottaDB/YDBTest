V1BOR10C ;IW-YS-TS,V1BOR,MVTS V9.10;15/6/96;BINARY OPERATOR  RELATIONAL: ']   -C-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"81---V1BOR10C: Binary operator  relational: ']   -C-",!
 ;
135 W !,"I-135  expratoms are strlit and numlit"
1351 S ^ABSN="11117",^ITEM="I-135.1  ""3""']3",^NEXT="13511^V1BOR10C,V1BOR10D^V1BOR,V1BOL^VV1" D ^V1PRESET
 S ^VCOMP="3"']3,^VCORR="1" D ^VEXAMINE
13511 S ^ABSN="11118",^ITEM="I-135.1.1  '(""3""]3)",^NEXT="1352^V1BOR10C,V1BOR10D^V1BOR,V1BOL^VV1" D ^V1PRESET
 S ^VCOMP='("3"]3),^VCORR="1" D ^VEXAMINE ;Test added in V7.4;16/9/89
1352 S ^ABSN="11119",^ITEM="I-135.2  ""3A""']3",^NEXT="13521^V1BOR10C,V1BOR10D^V1BOR,V1BOL^VV1" D ^V1PRESET
 S ^VCOMP="3A"']3,^VCORR="0" D ^VEXAMINE
13521 S ^ABSN="11120",^ITEM="I-135.2.1  '(""3A""]3)",^NEXT="1353^V1BOR10C,V1BOR10D^V1BOR,V1BOL^VV1" D ^V1PRESET
 S ^VCOMP='("3A"]3),^VCORR="0" D ^VEXAMINE ;Test added in V7.4;16/9/89
1353 S ^ABSN="11121",^ITEM="I-135.3  ""00123""']1",^NEXT="13531^V1BOR10C,V1BOR10D^V1BOR,V1BOL^VV1" D ^V1PRESET
 S ^VCOMP="00123"']1,^VCORR="1" D ^VEXAMINE
13531 S ^ABSN="11122",^ITEM="I-135.3.1  '(""00123""]1)",^NEXT="1354^V1BOR10C,V1BOR10D^V1BOR,V1BOL^VV1" D ^V1PRESET
 S ^VCOMP='("00123"]1),^VCORR="1" D ^VEXAMINE ;Test added in V7.4;16/9/89
1354 S ^ABSN="11123",^ITEM="I-135.4  ""ABCD""']1",^NEXT="13541^V1BOR10C,V1BOR10D^V1BOR,V1BOL^VV1" D ^V1PRESET
 S ^VCOMP="ABCD"']1,^VCORR="0" D ^VEXAMINE
13541 S ^ABSN="11124",^ITEM="I-135.4.1  '(""ABCD""]1)",^NEXT="1355^V1BOR10C,V1BOR10D^V1BOR,V1BOL^VV1" D ^V1PRESET
 S ^VCOMP='("ABCD"]1),^VCORR="0" D ^VEXAMINE ;Test added in V7.4;16/9/89
1355 S ^ABSN="11125",^ITEM="I-135.5  ""!""""""']0231",^NEXT="13551^V1BOR10C,V1BOR10D^V1BOR,V1BOL^VV1" D ^V1PRESET
 S ^VCOMP="!"""']0231,^VCORR="1" D ^VEXAMINE
13551 S ^ABSN="11126",^ITEM="I-135.5.1  '(""!""""""]0231)",^NEXT="1356^V1BOR10C,V1BOR10D^V1BOR,V1BOL^VV1" D ^V1PRESET
 S ^VCOMP='("!"""]0231),^VCORR="1" D ^VEXAMINE ;Test added in V7.4;16/9/89
1356 S ^ABSN="11127",^ITEM="I-135.6  +""3E-2A""']-3",^NEXT="13561^V1BOR10C,V1BOR10D^V1BOR,V1BOL^VV1" D ^V1PRESET
 S ^VCOMP=+"3E-2A"']-3,^VCORR="0" D ^VEXAMINE
13561 S ^ABSN="11128",^ITEM="I-135.6.1  '(+""3E-2A""]-3)",^NEXT="V1BOR10D^V1BOR,V1BOL^VV1" D ^V1PRESET
 S ^VCOMP='(+"3E-2A"]-3),^VCORR="0" D ^VEXAMINE ;Test added in V7.4;16/9/89
 ;
END W !!,"End of 81---V1BOR10C",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
