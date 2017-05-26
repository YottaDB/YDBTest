V1IDDOB ;IW-KO-TS,V1IDDO,MVTS V9.10;15/6/96;INDIRECTION IN DO COMMAND -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"152---V1IDDOB: Indirection in DO arguments -2-",!
468 W !,"I-468  Indirection of dlabel^routinename"
 S ^ABSN="11841",^ITEM="I-468  Indirection of dlabel^routinename",^NEXT="469^V1IDDOB,V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP=""
 S A="B",B=5,C="V1IDDO1" D @@A^@C S ^V1A="12^V1IDDO1" D @@"^V1A"
 S ^VCORR="5 12 " D ^VEXAMINE
 ;
469 W !,"I-469  Indirection of dlabel+intexpr^routinename"
 S ^ABSN="11842",^ITEM="I-469  Indirection of dlabel+intexpr^routinename",^NEXT="470^V1IDDOB,V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP=""
 S ^V1IDDO1="V1IDDO+1^V1IDDO1" D @^V1IDDO1
 S ^V1IDDO1="A",A=5,C="V1IDDO1" D AT+-3+@^V1IDDO1^@C
 S ^VCORR="V1IDDO+1 V1IDDO " D ^VEXAMINE
 ;
470 W !,"I-470  Argument level indirection without postcondition"
 S ^ABSN="11843",^ITEM="I-470  Argument level indirection without postcondition",^NEXT="471^V1IDDOB,V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP=""
 S ^V1A="0098",A="@^V1A,@(^V1A_0)",B="V1IDDO+2^@%,@C",%="V1IDDO1"
 S C="%^V1IDDOB,@(1_0)+1^V1IDDO1"
 D @A,@B
 S ^VCORR="0098 00980 V1IDDO+2 % 10+1 " D ^VEXAMINE
 ;
471 W !,"I-471  Argument level indirection with postcondition"
 S ^ABSN="11844",^ITEM="I-471  Argument level indirection with postcondition",^NEXT="472^V1IDDOB,V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP=""
 S A="%ABC^V1IDDO1:$L(0.023000)=4,10+100/51^V1IDDO1:^VCOMP[""%"""
 D:$L(0.02300)=4 @A
 S ^VCORR="%ABC 10+1 " D ^VEXAMINE
 ;
472 W !,"I-472  Indirection of argument list without postcondition"
 S ^ABSN="11845",^ITEM="I-472  Indirection of argument list without postcondition",^NEXT="473^V1IDDOB,V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP=""
 S A="%BREAK",B="SIEBEN7+@C-@C+1",C="D",D=10 D @A,@B
 S ^VCORR="%BREAK SIEBEN7+1 " D ^VEXAMINE
 ;
473 W !,"I-473  Indirection of argument list with postcondition"
 S ^ABSN="11846",^ITEM="I-473  Indirection of argument list with postcondition",^NEXT="474^V1IDDOB,V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP=""
 S ^V1IDDO1="A",A="""1ABCDE""" D @("ZEHN+"_@^V1IDDO1_"^V1"_"IDDO1:1=1,NOTHING^V1IDDO1:1=0")
 S A="MENU^V1IDDO1:A=A,ZEHN^V1IDDO1:1=0,@B+1^V1IDDO1",B="MENU" D @A
 S A=1,B="A" DO @A,@A+@B,@A+3-@B:@B=1
 S ^VCORR="ZEHN+1 MENU MENU+1 1 2 3 " D ^VEXAMINE
 ;
474 W !,"I-474  Indirection of postcondition"
 S ^ABSN="11847",^ITEM="I-474  Indirection of postcondition",^NEXT="V1IDARG^VV1" D ^V1PRESET
 S ^VCOMP="" K ^V1A,^V1IDDO1
 S A="A(K+0)",A(1)="ROUTINE",K=1
 D:@A="ROUTINE" @@A^V1IDDOB D:@A=1 @A^V1IDDOB D @@A^V1IDDOB:@A="ROUTINE"
 S A="A(1)",A(1)=1,^V1A(1)="^V1IDDO1",^V1IDDO1="V1IDDO1"
 S C(1)="C(11)",C(11)="1=1",C(2)="C(22)",C(22)="2=1"
 D:$D(@^V1A(@A))=1 98+1^@@^V1A(1),AT^V1IDDO1:@C(1),AT+1^V1IDDO1:@C(2)
 S ^VCORR="ROUTINE ROUTINE 00980 AT AT+1 " D ^VEXAMINE
 ;
END W !!,"End of 152---V1IDDOB",!
 K  K ^V1A,^V1IDDO1 Q
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
