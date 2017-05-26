V2READ ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;READ COUNT
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"18---V2READ: Read count"
140 W !!,"II-140  Terminated by readcount characters"
 S ^ABSN="20156",^ITEM="II-140  Terminated by readcount characters",^NEXT="141^V2READ,V2PAT1^VV2" D ^V2PRESET
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 read !,"   read X#3 : Type 3 characters 'ABC' and NEVER touch <CR> : ",X#3
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCOMP=X S ^VCORR="ABC"
 D AGAIN^VEXAMINE I RES="YES" G 140
 D ^VEXAMINE
 ;
141 W !!,"II-141  Terminated by <CR>"
 S ^ABSN="20157",^ITEM="II-141  Terminated by <CR>",^NEXT="142^V2READ,V2PAT1^VV2" D ^V2PRESET
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 r !,"   r X#10 : Type 3 characters 'ABC' and a <CR> : ",X#10
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCOMP=X S ^VCORR="ABC"
 D AGAIN^VEXAMINE I RES="YES" G 141
 D ^VEXAMINE
 ;
142 W !!,"II-142  Indirection argument"
 S ^ABSN="20158",^ITEM="II-142  Indirection argument",^NEXT="143^V2READ,V2PAT1^VV2" D ^V2PRESET
 S A="@B#COUNT",B="X",COUNT=10
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !,"   @A (R X#10) : Type 3 characters 'ABC' and a <CR> : ",@A
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCOMP=X S ^VCORR="ABC"
 D AGAIN^VEXAMINE I RES="YES" G 142
 D ^VEXAMINE
 ;
143 W !!,"II-143  Terminated by readcount characters"
 S ^ABSN="20159",^ITEM="II-143  Terminated by readcount characters",^NEXT="144^V2READ,V2PAT1^VV2" D ^V2PRESET
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 r !,"  r X#3:60 : Type 3 chars 'ABC' within 60 Seconds and NEVER touch <CR> : ",X#3:60
 S ^VCOMP=$T_" "_X S ^VCORR="1 ABC"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G 143
 D ^VEXAMINE
 ;
144 W !!,"II-144  Terminated by <CR>"
 S ^ABSN="20160",^ITEM="II-144  Terminated by <CR>",^NEXT="145^V2READ,V2PAT1^VV2" D ^V2PRESET
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 rEAD !,"   rEAD X#10:60 : Type 3 characters 'ABC' and a <CR> : ",X#10:60
 S ^VCOMP=$T_" "_X S ^VCORR="1 ABC"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G 144
 D ^VEXAMINE
 ;
145 W !!,"II-145  Terminated by timeout"
 S ^ABSN="20161",^ITEM="II-145  Terminated by timeout",^NEXT="146^V2READ,V2PAT1^VV2" D ^V2PRESET
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !,"  R X#10:15 : Type 3 chars 'ABC' within 15 seconds and NEVER touch <CR> : ",X#10:15
 S ^VCOMP=$T_" "_X S ^VCORR="0 ABC"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G 145
 D ^VEXAMINE
 ;
146 W !!,"II-146  Test of $TEST  when timeout time is 0"
 S ^ABSN="20162",^ITEM="II-146  Test of $TEST  when timeout time is 0",^NEXT="147^V2READ,V2PAT1^VV2" D ^V2PRESET
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !,"   R X#10:0 : Never touch any key : ",X#10:0
 S ^VCOMP=$T_X S ^VCORR="0"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G 146
 D ^VEXAMINE
 ;
147 W !!,"II-147  Indirection argument"
 S ^ABSN="20163",^ITEM="II-147  Indirection argument",^NEXT="V2PAT1^VV2" D ^V2PRESET
 S A="@B#@C:TIME",B="X",C="COUNT",COUNT=10,TIME=60.4
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !,"   @A (R X#10:60.4) : Type 3 characters 'ABC' and a <CR> : ",@A
 S ^VCOMP=$T_" "_X S ^VCORR="1 ABC"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G 147
 D ^VEXAMINE
 ;
END W !!,"End of 18---V2READ",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
