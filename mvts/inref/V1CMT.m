V1CMT ;IW-YS-TS,VV1,MVTS V9.10;15/6/96;STRUCTURE OF COMMENT
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"2---V1CMT: Structure of comment",!
 ;
186 W !,"I-186  Comment coming after ls"
 S ^ABSN="10005",^ITEM="I-186  Comment coming after ls",^NEXT="187^V1CMT,V1LL0^VV1" D ^V1PRESET
 ;(test changed in V7.5;20/8/90)
 W !,"       Following two lines should be identical:"
 S ^VCOMP="   Comment  "
 ;S ^VCOMP="** Comment FAIL  "
 S ^VCORR="   Comment  " D ^VEXAMINE
 ;
187 W !,"I-187  Comment coming after label ls"
 S ^ABSN="10006",^ITEM="I-187  Comment coming after label ls",^NEXT="188^V1CMT,V1LL0^VV1" D ^V1PRESET
 ;(test changed in V7.5;20/8/90)
 S ^VCOMP="PASS1  "
COMMENT ;S ^VCOMP=^VCOMP_"***** FAIL *****"
 S ^VCOMP=^VCOMP_"PASS2  "
 S ^VCORR="PASS1  PASS2  " D ^VEXAMINE
 ;
188 W !,"I-188  Comment coming after command argument"
 S ^ABSN="10007",^ITEM="I-188  Comment coming after command argument",^NEXT="189^V1CMT,V1LL0^VV1" D ^V1PRESET
 ;(test changed in V7.5;20/8/90)
 S ^VCOMP="After" ; S ^VCOMP=^VCOMP_"** FAIL After"
 S ^VCORR="After" D ^VEXAMINE
 ;
189 W !,"I-189  Comment coming after argumentless command with postconditional"
 S ^ABSN="10008",^ITEM="I-189  Comment coming after argumentless command with postconditional",^NEXT="190^V1CMT,V1LL0^VV1" D ^V1PRESET
 ;(test changed in V7.5;20/8/90)
 S ^VCOMP=""
 K:1  ;S ^VCOMP=^VCOMP_"FAIL  "
 S ^VCOMP=^VCOMP_"Argumentless pass"
 S ^VCORR="Argumentless pass" D ^VEXAMINE
 ;
190 W !,"I-190  Comment coming after argumentless command without postconditional"
 S ^ABSN="10009",^ITEM="I-190  Comment coming after argumentless command without postconditional",^NEXT="V1LL0^VV1" D ^V1PRESET
 ;(test changed in V7.5;20/8/90)
 S ^VCOMP="ABC "
 I 1 I  ; S ^VCOMP=^VCOMP_"** FAIL ****"
 S ^VCOMP=^VCOMP_"ABC"
 S ^VCORR="ABC ABC" D ^VEXAMINE
 ;
END W !!,"End of 2---V1CMT",!
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
