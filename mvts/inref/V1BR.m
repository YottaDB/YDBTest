V1BR ;IW-YS-KO-TS,V1BR,MVTS V9.10;15/6/96;BREAK COMMAND
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W:$Y>50 #
0 W !!,"181---V1BR: BREAK command"
 ;
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 W !!,"'*BREAK*' will appear in every occurence of active BREAK command."
 W !,"When you meet this message, Please type the command such as 'ZGO'"
 W !,"which is provided by this particular MUMPS implementation. If you "
 W !,"do not know this paticular restart command, Ask the implementer or "
 W !,"consult the mannual. By typing it followed by a carriage return should"
 W !,"resume the execution of this routine."
 W !,"If the execution is interrupted without this message,"
 W !,"it indicates that there is something wrong with BREAK command."
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 ;
 W:$Y>50 #
165 W !!,"I-165/166  Breaking point and restarting point"
 S ^ABSN="12045",^ITEM="I-165/166  Breaking point and restarting point",^NEXT="167^V1BR,V1READA^VV1" D ^V1PRESET
 S ^VCOMP=""
 S ^VCOMP=^VCOMP_1 W !!,"TEST 1: *BREAK*  Enter the resuming command --> : " BREAK  S ^VCOMP=^VCOMP_2
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE") ;(test corrected in V7.3;20/6/88)
 S ^VCORR="12" D ^VEXAMINE
 ;
 W:$Y>50 #
167 W !!,"I-167  BREAK postconditional"
 W !,"I-167.1  Postcondition is true"
 S ^ABSN="12046",^ITEM="I-167.1  Postcondition is true",^NEXT="1672^V1BR,V1READA^VV1" D ^V1PRESET
 S ^VCOMP=1 W !!,"TEST 2: *BREAK* (B:1=1  )  Enter the resuming command --> : " B:1=1  S ^VCOMP=^VCOMP_2
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE") ;(test corrected in V7.3;20/6/88)
 S ^VCORR="12" D ^VEXAMINE
 ;
1672 W !!,"I-167  BREAK postconditional" W:$Y>50 #
 W !,"I-167.2  Postcondition is false"
 S ^ABSN="12047",^ITEM="I-167.2  Postcondition is false",^NEXT="168^V1BR,V1READA^VV1" D ^V1PRESET
 W:$Y>50 #
 S ^VCOMP=1 W !!,"TEST 3: *BREAK* (B:0  )  DO NOT TOUCH! " B:0  S ^VCOMP=^VCOMP_2
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE") ;(test corrected in V7.3;20/6/88)
 S ^VCORR=12 D ^VEXAMINE
 ;
 W:$Y>50 #
168 W !!,"I-168  BREAK in internal routine in DO command"
 S ^ABSN="12048",^ITEM="I-168  BREAK in internal routine in DO command",^NEXT="169^V1BR,V1READA^VV1" D ^V1PRESET
 S ^VCOMP="A" W !!,"TEST 4: " D A S ^VCOMP=^VCOMP_"D"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE") ;(test corrected in V7.3;20/6/88)
 S ^VCORR="ABCD" D ^VEXAMINE
 ;
 W:$Y>50 #
169 W !!,"I-169  BREAK in external routine in DO command"
 S ^ABSN="12049",^ITEM="I-169  BREAK in external routine in DO command",^NEXT="170^V1BR,V1READA^VV1" D ^V1PRESET
 S ^VCOMP="A" D ^V1BR1 S ^VCOMP=^VCOMP_"D"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE") ;(test corrected in V7.3;20/6/88)
 S ^VCORR="ABCD" D ^VEXAMINE
 ;
 W:$Y>50 #
170 W !!,"I-170  BREAK in FOR loop"
 S ^ABSN="12050",^ITEM="I-170  BREAK in FOR loop",^NEXT="171^V1BR,V1READA^VV1" D ^V1PRESET
 S V=""
 F I=1:1:3 F J=1:1:3 S V=V_I_J_" " I I=2,J=2 S V=V_"$" W !!,"TEST 6: *BREAK*  Enter the resuming command --> : " B  S V=V_"! "
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE") ;(test corrected in V7.3;20/6/88)
 S ^VCOMP=V,^VCORR="11 12 13 21 22 $! 23 31 32 33 " D ^VEXAMINE
 ;
 W:$Y>50 #
171 W !!,"I-171  BREAK in XECUTE command"
 S ^ABSN="12051",^ITEM="I-171  BREAK in XECUTE command",^NEXT="V1READA^VV1" D ^V1PRESET
 S ^VCOMP=""
 S A="S ^VCOMP=^VCOMP_1 X B S ^VCOMP=^VCOMP_4",B="S ^VCOMP=^VCOMP_2 W !!,""TEST 7: *BREAK*  Enter the resuming command --> : "" B  S ^VCOMP=^VCOMP_3"
 X A S ^VCOMP=^VCOMP_5
 S ^VCOMP=^VCOMP_6
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE") ;(test corrected in V7.3;20/6/88)
 S ^VCORR="123456" D ^VEXAMINE
 ;
END W !!,"End of 181---V1BR",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
A S ^VCOMP=^VCOMP_"B" W "*BREAK* (B  )  Enter the resuming command --> : " B  S ^VCOMP=^VCOMP_"C" Q
