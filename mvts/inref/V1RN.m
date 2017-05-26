V1RN ;IW-YS-TS,VV1,MVTS V9.10;15/6/96;ACCEPTABLE ROUTINE NAMES
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"8---V1RN: Acceptable routine names",!
776 W !,"I-776  routinename is ""%"""
 S ^ABSN="10053",^ITEM="I-776  routinename is ""%""",^NEXT="777^V1RN,V1PRSET^VV1" D ^V1PRESET
 S VCOMP="" D ^%
 S ^VCOMP=VCOMP,^VCORR="% " D ^VEXAMINE
 ;
777 W !,"I-777  routinename is ""%"" followed by alpha and digit"
 S ^ABSN="10054",^ITEM="I-777  routinename is ""%"" followed by alpha and digit",^NEXT="778^V1RN,V1PRSET^VV1" D ^V1PRESET
 S VCOMP=""
 DO ^%1A
 S ^VCOMP=VCOMP,^VCORR="%1A " D ^VEXAMINE
 ;
778 W !,"I-778  routinename is alphas"
 S ^ABSN="10055",^ITEM="I-778  routinename is alphas",^NEXT="779^V1RN,V1PRSET^VV1" D ^V1PRESET
 S VCOMP="" D ^V
 D ^VA DO ^VAB
 D ^VABC D ^VABCD D ^VABCDE DO ^VABCDEF ;COMMENT
 S ^VCOMP=VCOMP,^VCORR="V VA VAB VABC VABCD VABCDE VABCDEF " D ^VEXAMINE
 ;
779 W !,"I-779  routinename is alpha followed by digits"
 S ^ABSN="10056",^ITEM="I-779  routinename is alpha followed by digits",^NEXT="780^V1RN,V1PRSET^VV1" D ^V1PRESET
 S VCOMP=""
 D ^V0
 D ^V01,^V012
 DO ^V4444,^V12345,^V000006
 SET ^VCOMP=VCOMP,^VCORR="V0 V01 V012 V4444 V12345 V000006 " D ^VEXAMINE
 ;
780 W !,"I-780  Maximum length of routinename"
 S ^ABSN="10057",^ITEM="I-780  Maximum length of routinename",^NEXT="V1PRSET^VV1" D ^V1PRESET
 S VCOMP="" D ^VABCDEFG
 D ^VABCDEFH
 D ^V7777777,^%2345678 D ^%BCDEFGH
 S ^VCOMP=VCOMP,^VCORR="VABCDEFG VABCDEFH V7777777 %2345678 %BCDEFGH " D ^VEXAMINE
 ;
END W !!,"End of 8---V1RN",!
 QUIT
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
