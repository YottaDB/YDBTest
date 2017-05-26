VSRE ;IW-KO-TS,VV1/VV2/VV3,MVTS V9.10;15/7/96;UTILITY
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 ;
 D GRAND
 W #,"                       8)  BACKGROUNDS FOR FAILURES"
 D LIN^VSR W !
 S NUMBER=0 D FAIL1,FAIL2,FAIL3,FAIL4
 D LIN^VSR
 W !,"END",!
 Q
 ;
GRAND ;
 W !,"       9)   GRAND TOTAL OF THE TEST RESULTS (Part-77, -84, -90, -94, -94TP)"
 W !,"             VALID TESTS:4318, WITHDRAWN OR SUPPRESSED TESTS: 93"
 W !,"   ======================================================================="
 W !,"                PASS (PASS+PASSO)   FAILURE (FAIL+FAILO+ABORT+SKIP)"
 W !,"    PART-77     ",$J(PASS("Part-77"),4),"                   ",$J(FAILURE("Part-77"),4)
 W !,"    PART-84     ",$J(PASS("Part-84"),4),"                   ",$J(FAILURE("Part-84"),4)
 W !,"    PART-90     ",$J(PASS("Part-90"),4),"                   ",$J(FAILURE("Part-90"),4)
 W !,"    PART-94(TP) ",$J(PASS("Part-94"),4),"                   ",$J(FAILURE("Part-94"),4)
 W !,"   ======================================================================="
 W !,"    TOTAL       ",$J(TPASS,4),"                   ",$J(FAILURE,4),!
 Q
 ;
FAIL1 S ^VREPORT="Part-77"
 F ABSN=10001:1:12156 D FVSR
 W "----------------------------------------",!
 Q
 ;
FAIL2 S ^VREPORT="Part-84"
 F ABSN=20001:1:20224 D FVSR
 W "----------------------------------------",!
 Q
 ;
FAIL3 S ^VREPORT="Part-90"
 F ABSN=30001:1:31108 D FVSR
 W "----------------------------------------",!
 Q
 ;
FAIL4 S ^VREPORT="Part-94"
 F ABSN=40001:1:40923 D FVSR
 Q
 ;
FVSR I $D(^VREPORT(^VREPORT,ABSN))#10=0 G SKIP
 S STAT=^VREPORT(^VREPORT,ABSN)
 I STAT["PASS" Q
 I STAT["WITHDR" Q
 S NUMBER=NUMBER+1 W NUMBER,".  No. ",ABSN,"  "
 I $D(^VREPORT(^VREPORT,ABSN,"ITEM")) W ^VREPORT(^VREPORT,ABSN,"ITEM")
 W !
 I STAT["*FAILO*" G FAILO
 I STAT["*FAIL*" G FAIL
 I STAT["*ABORT*" G ABORT
 Q
FAIL ;
 I $D(^VREPORT(^VREPORT,ABSN,"VCOMP")) W "                  COMPUTED =""",^VREPORT(^VREPORT,ABSN,"VCOMP"),"""",!
 I $D(^VREPORT(^VREPORT,ABSN,"VCORR")) W "                  CORRECT  =""",^VREPORT(^VREPORT,ABSN,"VCORR"),""""
 W ! Q
FAILO W "                  FAIL detected by OPERATOR.",! Q
FAILD W "                  FAIL detected automatically.",! Q
ABORT W "                  Test was aborted midway.",! Q
SKIP S NUMBER=NUMBER+1 W NUMBER,".  No. ",ABSN
 W !,"                  Test was skipped!",! Q
 ;
%DATE ;GET DATE ---> %DT
 S %DT=$P($H,",",1)
 S %H=%DT>21608+%DT+1460,%L=%H\1461,%YR=%H#1461
 S %Y=%L*4+1837+(%YR\365),%D=%YR#365+1
 S %M=1 I %YR=1460 S %D=366,%Y=%Y-1
 F %I=31,%Y#4=0+28,31,30,31,30,31,31,30,31,30,31 Q:%D'>%I  S %D=%D-%I,%M=%M+1
 S:%D<10 %D="0"_%D
 S %M=$E("JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC",%M*3-2,%M*3)
 S %DT=%M_" "_%D_", "_%Y
 K %H,%L,%YR,%Y,%M,%D,%I Q
%TIME ;GET TIME --> %T
 S %H=$P($H,",",2),%AMPM=" AM",%HR=%H\3600,%SM=%H#3600
 S %M=%SM\60,%S=%SM#60
 S:%M<10 %M=0_%M S:%S<10 %S=0_%S
 S %T=%HR_":"_%M
 K %H,%HR,%AMPM,%S,%M,%SM
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
