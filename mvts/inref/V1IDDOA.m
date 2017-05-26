V1IDDOA ;IW-KO-TS,V1IDDO,MVTS V9.10;15/6/96;INDIRECTION IN DO COMMAND -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"151---V1IDDOA: Indirection in1 DO arguments -1-",!
461 W !,"I-461  Indirection of dlabel"
 S ^ABSN="11834",^ITEM="I-461  Indirection of dlabel",^NEXT="462^V1IDDOA,V1IDDOB^V1IDDO,V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP="" S A=1 DO @A
 S ^VCORR="1 " D ^VEXAMINE
 ;
462 W !,"I-462  Indirection of dlabel, while dlabel contains indirection"
 S ^ABSN="11835",^ITEM="I-462  Indirection of dlabel, while dlabel contains indirection",^NEXT="463^V1IDDOA,V1IDDOB^V1IDDO,V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP="" S L="@L(1)",L(1)="@$P(""ONE/TWO/THREE"",""/"",2)"
 D @L
 S ^VCORR="TWO " D ^VEXAMINE
 ;
463 W !,"I-463  Indirection of dlabel+intexpr"
 S ^ABSN="11836",^ITEM="I-463  Indirection of dlabel+intexpr",^NEXT="464^V1IDDOA,V1IDDOB^V1IDDO,V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP="" S A="ENTRY" DO @A+00002+(2+3)-04 ;ENTRY+3
 S ^VCORR="ENTRY3 " D ^VEXAMINE
 ;
464 W !,"I-464  Indirection of dlabel+intexpr, while intexpr contains indirection"
 S ^ABSN="11837",^ITEM="I-464  Indirection of dlabel+intexpr, while intexpr contains indirection",^NEXT="465^V1IDDOA,V1IDDOB^V1IDDO,V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP="" S A=1,B="A" DO @A+@B ;1+1 ;(test corrected in V7.2;24/2/88)
 S ^VCORR="2 " D ^VEXAMINE
 ;
465 W !,"I-465  Indirection of dlabel+intexpr, while dlabel and intexpr contains"
 S ^ABSN="11838",^ITEM="I-465  Indirection of dlabel+intexpr, while dlabel and intexpr contains",^NEXT="466^V1IDDOA,V1IDDOB^V1IDDO,V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP=""
 S A="A(I)",I=02,A(2)="000001",^V1A="@B^@B(1)",B="0098",B(1)="V1IDDO1"
 D @@A+A(2),@^V1A
 S ^VCORR="000001+1 0098 " D ^VEXAMINE
 ;
466 W !,"I-466  Indirection of routine name"
 S ^ABSN="11839",^ITEM="I-466  Indirection of routine name",^NEXT="467^V1IDDOA,V1IDDOB^V1IDDO,V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP="" S A="V1IDDO1" D ^@A
 S B="^V1IDDO1" D @B
 S A="^V1IDDO1,^@B",B="V1IDDO1" D @A
 S ^VCORR="^V1IDDO1 ^V1IDDO1 ^V1IDDO1 ^V1IDDO1 " D ^VEXAMINE
 ;
467 W !,"I-467  Indirection of routine name, while routine name contains indirection"
 S ^ABSN="11840",^ITEM="I-467  Indirection of routine name, while routine name contains indirection",^NEXT="V1IDDOB^V1IDDO,V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP="" S ^V1IDDO1="A",A=10,C="V1IDDO1",V1IDDO1="V1IDDO1"
 D @A^@C,V1IDDO+-5+@^V1IDDO1^@@C
 S ^VCORR="10 98 " D ^VEXAMINE
 ;
END W !!,"End of 151---V1IDDOA",!
 K  K ^V1A,^V1IDDO1 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
98 S ^VCOMP=^VCOMP_"98 " Q
00980 S ^VCOMP=^VCOMP_"00980 " Q  ;470
0098 S ^VCOMP=^VCOMP_"0098 " Q  ;470
ROUTINE S ^VCOMP=^VCOMP_"ROUTINE " Q  ;474
1 S ^VCOMP=^VCOMP_"1 " Q  ;461,473
 S ^VCOMP=^VCOMP_"2 " Q  ;464,473
DREI S ^VCOMP=^VCOMP_"3 " Q  ;473
SIEBEN7 S ^VCOMP=^VCOMP_7 Q
 S ^VCOMP=^VCOMP_"SIEBEN7+1 " Q  ;472
%BREAK S ^VCOMP=^VCOMP_"%BREAK " Q  ;472
ENTRY S ^VCOMP=^VCOMP_"ENTRY " Q
 S ^VCOMP=^VCOMP_"ENTRY1 " Q
ENTRY2 S ^VCOMP=^VCOMP_"ENTRY2 " Q
 S ^VCOMP=^VCOMP_"ENTRY3 " Q  ;463
 QUIT
ONE S ^VCOMP=^VCOMP_"ONE " Q
TWO S ^VCOMP=^VCOMP_"TWO " Q  ;462
THREE S ^VCOMP=^VCOMP_"THREE " Q
% S ^VCOMP=^VCOMP_"% " Q
0123 S ^VCOMP=^VCOMP_"0123 " Q
012 S ^VCOMP=^VCOMP_"012 " Q
000001 S ^VCOMP=^VCOMP_"000001 " Q
 S ^VCOMP=^VCOMP_"000001+1 " Q  ;465
