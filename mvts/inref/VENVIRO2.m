VENVIRO2 ;IW-KO-TS,VENVIRON,MVTS V9.10;15/7/96;UTILITY
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1988-1996
TBL1 D 0 F %QQQ=1:1:25 W ! D @%QQQ D LONG
 Q
TBLN1 W ! F %QQQ=1:1:16 W !,%QQQ,". " D @%QQQ D LONG
 Q
TBLN2 W ! F %QQQ=17:1:32 W !,%QQQ,". " D @%QQQ D LONG
 Q
TBLN17 D WL F %QQQ=17:1:25 W !,%QQQ,". " S %QQQ0=%QQQ_"0" D @%QQQ0 D LONG
 D WL W !
 Q
LONG S T=^VENVIRON(SUB)
LONG1 IF $L(T)'>R W T Q
 F I=2:1:999 S T1=$P(T," ",1,I) I $L(T1)>R Q
 W $P(T," ",1,I-1)
 S T=$P(T," ",I,999),R=70 I T="" Q
 W !,"          " G LONG1
 ;
YES W !!,"VALIDATION ENVIRONMENT  #1/2"
 D TBLN1 D YES3
 IF RES="Y" G YES2
 IF RES="y" G YES2
 IF RES>0 IF RES<17 W ! D @RES^VENVIRON S ^VENVIRON(SUB)=D
 IF RES>16 IF RES<33 Q
 GOTO YES
YES2 W !!,"VALIDATION ENVIRONMENT  #2/2"
 D TBLN2 D YES3
 IF RES="Y" Q
 IF RES="y" Q
 IF RES>16 IF RES<33 W ! D @RES^VENVIRON S ^VENVIRON(SUB)=D
 IF RES>0 IF RES<17 G YES
 GOTO YES2
YES3 W !!,"   OK?   (Number of the item to edit, or Yy + <CR>) : " S RES="Y"
 Q
YES4 W !!,"   Number of the item to edit : " S RES="Y"
 Q
YES17 W ! D TBLN17 D YES17E I FLAG=0 D YES4 G YES171
 D YES3
 IF RES="Y" Q
 IF RES="y" Q
YES171 IF RES>16 IF RES<26 S RES1=+RES_"0" W ! D @RES1^VENVIRON S ^VENVIRON(SUB)=D
 GOTO YES17
YES17E S FLAG=1 F SUB="#1 MODEL","#1 OPEN","#1 USE","#1 USE","#1 CLOSE","#2 MODEL","#2 OPEN","#2 USE","#2 USE","#2 CLOSE" S FLAG=FLAG*$L(^VENVIRON(SUB))
 S FLAG=FLAG*(^VENVIRON("TURNED ON")="YES")
 Q
 ;
0 W !,"                       1)  VALIDATION ENVIRONMENT"
 D WL W !,"INTEGRITY STATUS OF MVS V9.10: ",^VENVIRON("INTEGRITY")
 D WL W !,"The MVS V9.10 has 4318 Valid, 8 Optional, and 93 Withdrawn Tests."
 D WL
 Q
1 W "Customer Name: " S R=58,SUB="Customer" Q
2 W "Test Date: " S R=62,SUB="Date" Q
3 W "Test Site: " S R=62,SUB="Site" Q
4 W "Implementation Name and Version/Release: " S R=32,SUB="Implementation" Q
5 W "Host Computer System: " S R=51,SUB="Host" Q
6 W "Target Computer System: " S R=49,SUB="Target" Q
7 W "POC for Technical Information: " S R=42,SUB="Technical" Q
8 W "POC for Sales Information: " S R=46,SUB="Sales" Q
9 W "Principal Keyboard (Name/Model): " S R=40,SUB="INPUT MODEL" Q
10 W "   Its precise OPEN Argument, with Parameters : "
 S R=25,SUB="INPUT OPEN" Q
11 W "   Its USE Argument   : " S R=49,SUB="INPUT USE" Q
12 W "   Its default USE Argument : " S R=43,SUB="DEFAULT" Q
13 W "Principal Printer or CRT (Name/Model): " S R=34,SUB="OUTPUT MODEL" Q
14 W "   Its precise OPEN Argument, with Parameters : "
 S R=25,SUB="OUTPUT OPEN" Q
15 W "   Its USE Argument   : " S R=49,SUB="OUTPUT USE" Q
16 W "   Its CLOSE Argument : " S R=49,SUB="OUTPUT CLOSE" Q
170 ;
17 W "The Secondary Output Device for I/O and Multi-Job tests (Name/Model): "
 S R=7,SUB="#1 MODEL" Q
180 ;
18 W "   Its precise OPEN Argument, with Parameters : "
 S R=25,SUB="#1 OPEN" Q
190 ;
19 W "   Its USE Argument   : " S R=49,SUB="#1 USE" Q
200 ;
20 W "   Its CLOSE Argument : " S R=49,SUB="#1 CLOSE" Q
210 ;
21 W "The Tertiary Output Device for I/O and Multi-Job tests (Name/Model): "
 S R=8,SUB="#2 MODEL" Q
220 ;
22 W "   Its precise OPEN Argument, with Parameters : "
 S R=25,SUB="#2 OPEN" Q
230 ;
23 W "   Its USE Argument   : " S R=49,SUB="#2 USE" Q
240 ;
24 W "   Its CLOSE Argument : " S R=49,SUB="#2 CLOSE" Q
250 ;
25 W "Secondary, Tertiary, and Partition terminals turned ON : "
 S R=16,SUB="TURNED ON" Q
 ;
26 W "The VSR Output Printer : " S R=41,SUB="#3 MODEL" Q
27 W "   Its precise OPEN Argument, with Parameters : "
 S R=26,SUB="#3 OPEN" Q
28 W "   Its USE Argument   : " S R=49,SUB="#3 USE" Q
29 W "   Its CLOSE Argument : " S R=49,SUB="#3 CLOSE" Q
30 W "The Output Device for VSR as Sequential File if reuired.",!
 W "       Its precise OPEN Argument with Parameters (<CR> to ignore): ",!
 W "          Ex:  51:(""VSR.LOG"":""W""),  10:(file=""VSR.LOG"":mode=""W"")",!
 W "                      : "
 S R=49,SUB="#4 OPEN" Q
31 W "   Its USE Argument   : "
 S R=49,SUB="#4 USE" Q
32 W "   Its CLOSE Argument : "
 S R=49,SUB="#4 CLOSE" Q
WL W !,"============================================================================" Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
TITL W !!!!,"                          THE VALIDATION ENVIRONMENT"
 W !!!,"Answer each question so that Validation process is automated."
 W !,"Entries may be edited at the end of questions.",!
 D WL^VENVIRO2
 Q
