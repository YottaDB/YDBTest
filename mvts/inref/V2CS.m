V2CS ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;COMMAND SPACE
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"1---V2CS: Command spaces",!
1 W !,"II-1  cs between ls and comment"
 S ^ABSN="20001",^ITEM="II-1  cs between ls and comment",^NEXT="2^V2CS,V2LCC1^VV2" D ^V2PRESET
 S ^VCOMP=1
              ;S ^VCOMP="ERROR"
 S ^VCORR="1" D ^VEXAMINE
 ;
2 W !,"II-2  cs between command and command"
 S ^ABSN="20002",^ITEM="II-2  cs between command and command",^NEXT="3^V2CS,V2LCC1^VV2" D ^V2PRESET
 S ^VCOMP=1             S ^VCOMP=^VCOMP_2                                                          S ^VCOMP=^VCOMP_3
 S ^VCORR=123 D ^VEXAMINE
 ;
3 W !,"II-3  cs after IF command"
 S ^ABSN="20003",^ITEM="II-3  cs after IF command",^NEXT="4^V2CS,V2LCC1^VV2" D ^V2PRESET
 S ^VCOMP=""
 I 1         I           S ^VCOMP=^VCOMP_4 S:0 ^VCOMP=^VCOMP_1
 I                       S ^VCOMP=^VCOMP_5
 S ^VCORR=45 D ^VEXAMINE
 ;
4 W !,"II-4  cs after ELSE command"
 S ^ABSN="20004",^ITEM="II-4  cs after ELSE command",^NEXT="5^V2CS,V2LCC1^VV2" D ^V2PRESET
 S ^VCOMP=""
 I .1    S ^VCOMP=^VCOMP_"1"
 E      S ^VCOMP="ELSE-cs --ERROR"
 I 0    S ^VCOMP=^VCOMP_" IF 0 "
 E      S ^VCOMP=^VCOMP_5
 S ^VCORR="15" D ^VEXAMINE
 ;
5 W !,"II-5  cs among FOR - QUIT - DO command"
 S ^ABSN="20005",^ITEM="II-5  cs among FOR - QUIT - DO command",^NEXT="6^V2CS,V2LCC1^VV2" D ^V2PRESET
 S ^VCOMP=""
 F I=6:1:8         Q:I=10       D:1 A:I>0      ;
 F I=9:1:15        QUIT:I=11       DO A       ;
 S ^VCORR="678910" D ^VEXAMINE
 ;
6 W !,"II-6  cs between ls and comment in XECUTE command"
 S ^ABSN="20006",^ITEM="II-6  cs between ls and comment in XECUTE command",^NEXT="7^V2CS,V2LCC1^VV2" D ^V2PRESET
 S ^VCOMP=""
 S A="           ; S ^VCOMP=""ls-cs-comment in XECUTE -- ERROR """ X A
 S ^VCORR="" D ^VEXAMINE
 ;
7 W !,"II-7  cs between commands in XECUTE command"
 S ^ABSN="20007",^ITEM="II-7  cs between commands in XECUTE command",^NEXT="8^V2CS,V2LCC1^VV2" D ^V2PRESET
 S ^VCOMP=""
 S A="   S ^VCOMP=11               S ^VCOMP=^VCOMP_12     ;COMMENT"   X A    ;
 S ^VCORR="1112" D ^VEXAMINE
 ;
8 W !,"II-8  cs between commands with indirection argument"
 S ^ABSN="20008",^ITEM="II-8  cs between commands with indirection argument",^NEXT="V2LCC1^VV2" D ^V2PRESET
 S ^VCOMP="",A="B",B=13,C="D=14",E="E1",E1=15
 S ^VCOMP=@A    S @C      S ^VCOMP=^VCOMP_D,F=@E       SET ^VCOMP=^VCOMP_F    ;
 S ^VCORR="131415" D ^VEXAMINE
 ;
END W !!,"End of 1---V2CS",!
 K    Q    ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
A S ^VCOMP=^VCOMP_I      Q     ;
