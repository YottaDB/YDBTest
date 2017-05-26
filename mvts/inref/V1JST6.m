V1JST6 ;IW-YS-KO-TS,V1JST,MVTS V9.10;15/6/96; $JUSTIFY, $SELECT, $TEXT -6-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"175---V1JST6: $JUSTIFY, $SELECT and $TEXT functions -6-",!
 ;
TEXT W !!,"$TEXT(lineref),  $TEXT(+intexpr)",!
593 W !,"I-593  The line specified by lineref does not exist"
 S ^ABSN="12018",^ITEM="I-593  The line specified by lineref does not exist",^NEXT="594^V1JST6,V1SVH^VV1" D ^V1PRESET
 S ^VCOMP="123" S ^VCOMP=$TEXT(QQQQQQ),^VCORR="" D ^VEXAMINE
 ;
594 W !,"I-594  The line specified by +intexpr does not exist"
 S ^ABSN="12019",^ITEM="I-594  The line specified by +intexpr does not exist",^NEXT="595^V1JST6,V1SVH^VV1" D ^V1PRESET
 S ^VCOMP="123" S ^VCOMP=$T(+500),^VCORR="" D ^VEXAMINE
 ;
595 W !,"I-595  The line specified by lineref exist"
5951 S ^ABSN="12020",^ITEM="I-595.1  lineref is a label",^NEXT="5952^V1JST6,V1SVH^VV1" D ^V1PRESET
 S ^VCOMP=$TEXT(Z1),^VCORR="Z1 ;THE $TEXT TEST 1" D ^VEXAMINE
 ;
5952 S ^ABSN="12021",^ITEM="I-595.2  lineref is a another label",^NEXT="5953^V1JST6,V1SVH^VV1" D ^V1PRESET
 S ^VCOMP=$T(595)
 S ^VCORR="595 W !,""I-595  The line specified by lineref exist""" D ^VEXAMINE
 ;
5953 S ^ABSN="12022",^ITEM="I-595.3  Nesting of function",^NEXT="596^V1JST6,V1SVH^VV1" D ^V1PRESET
 S ^VCOMP=$P($TEXT(TEXT),"  ",2)
 S ^VCORR="$TEXT(+intexpr)"",!" D ^VEXAMINE
 ;
596 W !,"I-596  The line specified by +intexpr exist"
 S ^ABSN="12023",^ITEM="I-596  The line specified by +intexpr exist",^NEXT="597^V1JST6,V1SVH^VV1" D ^V1PRESET
 S ^VCOMP=$T(+2.5),^VCORR=" ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996" D ^VEXAMINE
 ;
597 W !,"I-597  lineref=label"
 S ^ABSN="12024",^ITEM="I-597  lineref=label",^NEXT="598^V1JST6,V1SVH^VV1" D ^V1PRESET
 S ^VCOMP=$T(Z4),^VCORR="Z4 ;THE $TEXT ""TEST"" 4" D ^VEXAMINE
 ;
598 W !,"I-598  lineref=label+intexpr"
 S ^ABSN="12025",^ITEM="I-598  lineref=label+intexpr",^NEXT="599^V1JST6,V1SVH^VV1" D ^V1PRESET
 S ^VCOMP=$T(Z1+1),^VCORR="Z2 ;" D ^VEXAMINE
 ;
599 W !,"I-599/600  Indirection of argument"
 S ^ABSN="12026",^ITEM="I-599/600  Indirection of argument",^NEXT="V1SVH^VV1" D ^V1PRESET
 S X="Z4",Y=0,Z="Y",^VCOMP=$T(@X+@Z),^VCORR="Z4 ;THE $TEXT ""TEST"" 4" D ^VEXAMINE
 ;
END W !!,"End of 175---V1JST6",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
Z1 ;THE $TEXT TEST 1
Z2 ;
Z4 ;THE $TEXT "TEST" 4
