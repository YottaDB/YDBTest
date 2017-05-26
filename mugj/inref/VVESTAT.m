VVESTAT	;VALIDATION REPORT PROGRAM --UTILITY--;TS,VVE,VALIDATION VERSION 7.1;31-AUG-87;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;Q
STATIS	;
	I $D(^VREPORT)=0 W !!,"*** CANNOT REPORT WRITING, BECASE DOES NOT EXIST ^VREPORT GLOBAL ***",!! Q
	I $Y'=0 W #
	D %DATE,%TIME
	W "Final Evaluation of Std. MUMPS conformance Test V.7.1.   Part-III",!
	W "  ( Blanks in visual checks must be manually filled in.)",!!
	W "                                                ",%DT,"   ",%T,! K %DT,%T
	S ^VREPORT(100000,0)=0,^VREPORT(100000,1)=0
	D DISPF S SEQ=0 F I=0:0 S SEQ=$O(^VREPORT(SEQ)) Q:SEQ>10000  D SET,DISP1
	D TOTAL
	Q
SET	S ^VREPORT(100000,0)=^VREPORT(100000,0)+1 ;count
	S VAL=^VREPORT(SEQ)
	S ROUTINE=$P(VAL,"^",1) ;routine name
	S LABEL=$P(VAL,"^",2) ;label
	S NUMBER=$P(VAL,"^",3) ;test number
	S AUTO=$P(VAL,"^",4)
	I AUTO'="" S ^VREPORT(100000,1)=^VREPORT(100000,1)+1 ;Defects detected automat.
	Q
DISP1	;display each test result
	W "|",$J(SEQ,7)_" |"
	W $E(" "_ROUTINE_".............",1,12)
	W "..",LABEL,"..",$E(NUMBER_"   ",1,9),"|         |"
	I AUTO="" W "    ----"
	E  W "  defect"
	W "  |          |",!
	I $Y>55 D DISPL W # D DISPF
	Q
TOTAL	D DISPL
	W "|  TOTAL |                       ",$J(^VREPORT(100000,0),2)
	W " |         |       ",$J(^VREPORT(100000,1),2)
	W " |          |",!
	I $Y>55 D DISPL W #
	D DISPL
	Q
DISPF	D DISPL
	W "|Checked | Routine   Label  Test    |Pass       Defects    Defects  |",!
	W "|sequence|    name           number | detected   detected   detected|",!
	W "|        |                          | visual.    automat.   visual. |",!
DISPL	;
	W "+--------+---------+------+---------+---------+----------+----------+",!
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
