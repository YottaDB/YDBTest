;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
V3ALDO1 ;IW-KO-YS-TS,V3ALDO,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 ;
 W !!,"134---V3ALDO1: Argumentless DO command -1-"
1 S ^ABSN="31067",^ITEM="III-1067  Lines to be are ignored"
 ; From GT.M V63002, the below code block issues a BLKTOODEEP warning at compile time.
 ; It is not clear what the below code is supposed to do with respect to argumentless DO.
 ; Therefore this is currently commented out.
 ;
 ;S ^NEXT="2^V3ALDO1,V3ALDO2^V3ALDO,V3FP^VV3" D ^V3PRESET
 ;S ^VCOMP="OK"
 ;. S ^VCOMP="ERROR1"
 ;.. S ^VCOMP="ERROR2"
 ;. . S ^VCOMP="ERROR3"
 ;S ^VCORR="OK" D ^VEXAMINE
 ;
2 S ^ABSN="31068",^ITEM="III-1068  $TEST value"
 S ^NEXT="3^V3ALDO1,V3ALDO2^V3ALDO,V3FP^VV3" D ^V3PRESET
 W !,"      (This test III-1068 was withdrawn in 15/2/1994 on X11.1-1990, MSL)"
 S ^VREPORT("Part-90",^ABSN)="*WITHDR*"
 ;
3 S ^ABSN="31069",^ITEM="III-1069  GOTO command in an argumentless DO scope"
 S ^NEXT="4^V3ALDO1,V3ALDO2^V3ALDO,V3FP^VV3" D ^V3PRESET
 S ^VCOMP="",F=0 D
A . S ^VCOMP=^VCOMP_"A" Q:F=1
 . S ^VCOMP=^VCOMP_"B" DO  G ABC
 . . S ^VCOMP=^VCOMP_"C"
 . S ^VCOMP=^VCOMP_"F"
ABC . S ^VCOMP=^VCOMP_"D",F=1 G A
 . S ^VCOMP=^VCOMP_"E"
 S ^VCORR="ABCDA" D ^VEXAMINE
 ;
4 S ^ABSN="31070",^ITEM="III-1070  DO command in an argumentless DO scope"
 S ^NEXT="V3ALDO2^V3ALDO,V3FP^VV3" D ^V3PRESET
 S ^VCOMP="" d  S ^VCOMP=^VCOMP_"D"
 . S ^VCOMP=^VCOMP_"A" d A^V3ALDOE S ^VCOMP=^VCOMP_"B"
 . S ^VCOMP=^VCOMP_"C" D
 . . d A^V3ALDOE
 S ^VCOMP=^VCOMP_"E"
 S ^VCORR="AZBCZDE" D ^VEXAMINE
 ;
END W !!,"End of 134 --- V3ALDO1 ",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
