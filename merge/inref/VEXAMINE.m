VEXAMINE ;IW-KO-TS,VV1/VV2/VV3/VV4/VV4TP,MVTS V9.10;15/7/96;UTILITY
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 ;
 ; Part-77, Part-84, Part-90, Part-94
 I $E(^ABSN,1)="1" S ^VREPORT="Part-77"
 I $E(^ABSN,1)="2" S ^VREPORT="Part-84"
 I $E(^ABSN,1)="3" S ^VREPORT="Part-90"
 I $E(^ABSN,1)="4" S ^VREPORT="Part-94"
 I ^ABSN>40866,^ABSN<40924 S ^VREPORT="Part-94" G TP
 ;
 K ^VREPORT(^VREPORT,^ABSN,"VCOMP"),^VREPORT(^VREPORT,^ABSN,"VCORR")
 I ^VCORR=^VCOMP W !,"   PASS  ",^ABSN," ",^ITEM S ^VREPORT(^VREPORT,^ABSN)=" PASS " W:$Y>55 # Q
 W !,"** FAIL  ",^ABSN," ",^ITEM S ^VREPORT(^VREPORT,^ABSN)="*FAIL*" W:$Y>55 #
 S ^VREPORT(^VREPORT,^ABSN,"VCOMP")=^VCOMP
 S ^VREPORT(^VREPORT,^ABSN,"VCORR")=^VCORR
 W !,"           COMPUTED =""",^VCOMP,"""" W:$Y>55 #
 W !,"           CORRECT  =""",^VCORR,"""" W:$Y>55 #
 H 1 Q
 ;
TP ;---------------- Transaction
 LOCK
 S ^HALT=1 H 1
 K ^VREPORT(^VREPORT,^ABSN,"VCOMP"),^VREPORT(^VREPORT,^ABSN,"VCORR")
 I ^VCOMP=^VCORR W !,"   PASS  ",^ABSN," ",$P(^ITEM,"!",1) S ^VREPORT(^VREPORT,^ABSN)=" PASS " d  W:$Y>55 # Q
 . i $P(^ITEM,"!",2)=""  q
 . F I=2:1:$L(^ITEM,"!") W !,"                       ",$p(^ITEM,"!",I)
 W !,"  *FAIL  ",^ABSN," ",$p(^ITEM,"!",1) S ^VREPORT(^VREPORT,^ABSN)="*FAIL*" d  W:$Y>55 #
 . i $p(^ITEM,"!",2)=""  q
 . F I=2:1:$L(^ITEM,"!") W !,"                       ",$p(^ITEM,"!",I)
 S ^VREPORT(^VREPORT,^ABSN,"VCOMP")=^VCOMP
 S ^VREPORT(^VREPORT,^ABSN,"VCORR")=^VCORR
 W !,"           COMPUTED =""",^VCOMP,"""" W:$Y>55 #
 W !,"           CORRECT  =""",^VCORR,"""" W:$Y>55 #
 H 3 Q
 ;
MANPF2 ; Part-84
 S ^VREPORT="Part-84" G MANPF
MANPF1 ; Part-77
 S ^VREPORT="Part-77"
MANPF I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
MANPFYN W !!,"Before answering the PASS-FAIL question,"
 W !,"do you want to repeat this test? (Yy/Nn + <CR>): " R RES
 I RES="Y" S RES="AGAIN" G PFAG
 I RES="y" S RES="AGAIN" G PFAG
 I RES="N" S RES="NO" G REP
 I RES="n" S RES="NO" G REP
 G MANPFYN
REP W !,"Press P/p for PASS or F/f for FAIL and <CR> : " R RES
REPA I RES="P" W !,"PASS " G PFEXIT
 I RES="p" W !,"PASS " S RES="P" G PFEXIT
 I RES="F" W !,"FAIL " G PFEXIT
 I RES="f" W !,"FAIL " S RES="F" G PFEXIT
 G REP
PFEXIT R " OK?   (Yy/Nn + <CR>): ",OK W !
 I OK="Y" K OK G PFEXIT1
 I OK="y" K OK G PFEXIT1
 I OK="N" G REP
 I OK="n" G REP
 G REPA
PFEXIT1 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 I RES="P" W !,"   PASS  ",^ABSN," ",^ITEM S ^VREPORT(^VREPORT,^ABSN)=" PASSO " W:$Y>55 # K  Q
 I RES="F" W !,"** FAIL  ",^ABSN," ",^ITEM S ^VREPORT(^VREPORT,^ABSN)="*FAILO*" W:$Y>55 #
 K  Q
 ;
 ;
AGAIN ;
 I ^VCORR=^VCOMP S RES="NO" Q
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
REPAG W !!,"Test has FAILed."
 W !,"Do you want to repeat this test?  (Yy/Nn + <CR>): " R RES W !
 I RES="Y" S RES="YES" G PFAG
 I RES="y" S RES="YES" G PFAG
 I RES="N" S RES="NO" G PFAG
 I RES="n" S RES="NO" G PFAG
 G REPAG
PFAG I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 Q
 ;
OPT ;$RANDOM option test
 K
 I ^VCORR'=^VCOMP W !,"   PASS  ",^ABSN," ",^ITEM S ^VREPORT("Part-77",^ABSN)=" PASS " W:$Y>55 # Q
 W !,"** FAIL  ",^ABSN," ",^ITEM,"     All sub-tests are out of limits"
 S ^VREPORT("Part-77",^ABSN)="*FAIL*"
 W:$Y>55 #
 H 1 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
