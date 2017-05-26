VREPORT	;VALIDATION REPORT PROGRAM --UTILITY--;TS,,VALIDATION VERSION 7.1;31-AUG-87;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	;Q
	I $D(^VREPORT)=0 Q
	I $Y>55 W #
	W !,"-----------------------------------------------------------------------"
	W !,"     END OF TEST -- ",ROUTINE,"      Std. MUMPS Conformance Test V.7.1." I $Y>55 W #
	W !,?5,TESTS," tests were executed." I $Y>55 W #
	I VISUAL=0 W !,?5,$J(VISUAL,4)," visual    Test(s)." I $Y>55 W #
	I VISUAL W !,?5,$J(VISUAL,4)," visual    Test(s) ( _____ passed, _____ failed )." I $Y>55 W #
	I TESTS=VISUAL S PASS=0,FAIL=0 W !,?5,$J(AUTO,4)," automatic Test(s)." I $Y>55 W #
	I TESTS'=VISUAL W !,?5,$J(AUTO,4)," automatic Test(s) (",$J(PASS,6)," passed,",$J(FAIL,6)," failed,",$J(AUTO-PASS-FAIL,4)," aborted! )." I $Y>55 W #
	W ! I $Y>55 W #
	W ! I $Y>55 W #
	;Q
	S ^VREPORT(0)=^VREPORT(0)+1 ;executed order number
	S EXEORDER=^VREPORT(0)
	S ^VREPORT(EXEORDER)=ROUTINE ;routine name
	S ^VREPORT(EXEORDER,0)=FAIL ;fail count
	S ^VREPORT(EXEORDER,1)=PASS ;pass count
	S ^VREPORT(EXEORDER,2)=AUTO ;AUTO=PASS+FAIL
	S ^VREPORT(EXEORDER,3)=VISUAL ;visual test
	S ^VREPORT(EXEORDER,4)=TESTS ;TESTS=AUTO+VISUAL
	Q
	;
STATIS	;
	I $D(^VREPORT)=0 W !!,"*** CANNOT REPORT WRITING, BECASE DOES NOT EXIST ^VREPORT GLOBAL ***",!! Q
	I $Y'=0 W #
	D %DATE,%TIME
	W "Final Evaluation of Std. MUMPS conformance Test V.7.1.   "
	W:$D(^VREPORT)#10=1 ^VREPORT W !
	W "  ( Blanks in visual checks must be manually filled in.)",!!
	W "                                                   ",%DT,"   ",%T,! K %DT,%T
	S ^VREPORT(100000,0)=0,^VREPORT(100000,1)=0
	S ^VREPORT(100000,2)=0,^VREPORT(100000,3)=0,^VREPORT(100000,4)=0
	D DISPF S NO=0 F I=0:0 S NO=$O(^VREPORT(NO)) Q:NO>10000  D SET,DISP1
	D TOTAL
	Q
SET	S ROUTINE=^VREPORT(NO)
	S FAIL=^VREPORT(NO,0),^VREPORT(100000,0)=^VREPORT(100000,0)+FAIL
	S PASS=^VREPORT(NO,1),^VREPORT(100000,1)=^VREPORT(100000,1)+PASS
	S AUTO=^VREPORT(NO,2),^VREPORT(100000,2)=^VREPORT(100000,2)+AUTO
	S VISUAL=^VREPORT(NO,3),^VREPORT(100000,3)=^VREPORT(100000,3)+VISUAL
	S TESTS=^VREPORT(NO,4),^VREPORT(100000,4)=^VREPORT(100000,4)+TESTS
	Q
DISP1	W "|",$J(NO,7)_" "
	W "|",$E(" "_ROUTINE_"........",1,9)
	S TP=".........."_TESTS
	W ".",$E(TP,$L(TP)-6,$L(TP))," (",$J(VISUAL,4),")|"
	I TESTS=VISUAL W "  None   None"
	E  W $J(PASS,6) ;auto pass
	E  W " ",$J(FAIL,6) ;auto fail
	W " ",$J(AUTO-PASS-FAIL,8) ;aborted !
	I VISUAL=0 W "|  None   None"
	E  W "|             "
	W "|",!
	I $Y>55 D DISPL W # D DISPF
	Q
TOTAL	S FAIL=^VREPORT(100000,0)
	S PASS=^VREPORT(100000,1)
	S AUTO=^VREPORT(100000,2)
	S VISUAL=^VREPORT(100000,3)
	S TESTS=^VREPORT(100000,4)
	D DISPL
	W "| TOTAL  | ........." S TP=".........."_TESTS
	W $E(TP,$L(TP)-6,$L(TP))," (",$J(VISUAL,4),")|"
	I TESTS=VISUAL W "  None   None"
	E  W $J(PASS,6) ;auto pass
	E  W " ",$J(FAIL,6) ;auto fail
	W " ",$J(AUTO-PASS-FAIL,8) ;aborted !
	I VISUAL=0 W "|  None   None"
	E  W "|(",$J(VISUAL,2),")         "
	W "|",!
	I $Y>55 D DISPL W #
	D DISPL
	Q
DISPF	D DISPL
	W "|executed| routine    tests       | auto   auto  aborted!|    visual   |",!
	W "|  order |    name        (visual)| pass   fail          | pass   fail |",!
DISPL	;
	W "+--------+----------+-------------+------+------+--------+------+------+",!
	Q
%DATE	;GET DATE ---> %DT
	S %DT=$P($H,",",1)
	S %H=%DT>21608+%DT+1460,%L=%H\1461,%YR=%H#1461
	S %Y=%L*4+1837+(%YR\365),%D=%YR#365+1
	S %M=1 I %YR=1460 S %D=366,%Y=%Y-1
	F %I=31,%Y#4=0+28,31,30,31,30,31,31,30,31,30,31 Q:%D'>%I  S %D=%D-%I,%M=%M+1
	S:%D<10 %D="0"_%D
	S %M=$E("JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC",%M*3-2,%M*3)
	S %DT=%M_" "_%D_", "_%Y
	K %H,%L,%YR,%Y,%M,%D,%I Q
%TIME	;GET TIME --> %T
	S %H=$P($H,",",2),%AMPM=" AM",%HR=%H\3600,%SM=%H#3600
	S %M=%SM\60,%S=%SM#60
	S:%M<10 %M=0_%M S:%S<10 %S=0_%S
	S %T=%HR_":"_%M
	K %H,%HR,%AMPM,%S,%M,%SM Q
