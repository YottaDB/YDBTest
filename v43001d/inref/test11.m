test11	;
	; test that GOTO in $ETRAP does rethrow error if quit with non-NULL $ECODE from an error frame
	;
ZZTRAP	;SF/RWF - TEST OF ERROR TRAPPING. ;08/20/2002  16:41
	;;
	;This routine is used to show how the new error trapping works
A	S $ECODE="" ;This is to be sure that $ECODE is null comming from progmode
	N $ES,$ET S $ETRAP="D TR^test11"
	S EL=10,LV=5
	;R !,"At what level should we cause an error: ",EL,!,"Pop back to level: ",LV
	W !!,"Make calls untill we get ",EL," deep, Cause an error. Pop to level ",LV," then exit."
	S CNT=0,SHOW="TOP"
	D B
	Q
B	;
	N SHOW S CNT=CNT+1,SHOW="B"_CNT
	W !,"Now at level CNT:",$J(CNT,3)," and $ESTACK:",$J($ES,3)
	I CNT>LV
	I CNT=EL W 1/0 W !,"** Rest of error line" Q
	I CNT=LV N $ES,$ET S $ETRAP="D TR^test11" W "  Setting a new ETRAP."
	S X=$$C() W !,"Continue in normal M,",?33," $ESTACK:",$J($ES,3),"  SHOW=",SHOW
	;S X=$$E^ZZTRAP2() W !,"Continue in normal M,",?33," $ESTACK:",$J($ES,3),"  SHOW=",SHOW
	Q
C()	;EF.
	N SHOW S CNT=CNT+1,SHOW="B"_CNT
	D  Q 1
	. W !,"Now at level CNT:",$J(CNT,3)," and $ESTACK:",$J($ES,3)
	. I CNT=EL W 1/0 W !,"** Rest of error line" Q
	. I CNT=LV N $ES,$ET S $ETRAP="D TR^test11" W "  Setting a new ETRAP."
	. D D(CNT) W !,"Continue in Extrinsic,",?33," $ESTACK:",$J($ES,3),"  SHOW=",SHOW
	. Q
	Q
D(X)	;PP.
	N SHOW S CNT=CNT+1,SHOW="B"_CNT
	W !,"Now at level CNT:",$J(CNT,3)," and $ESTACK:",$J($ES,3)
	I CNT=EL W 1/0 W !,"** Rest of error line" Q
	I CNT=LV N $ES,$ET S $ETRAP="D TR^test11" W "  Setting a new ETRAP."
	D B W !,"Continue in Parameter passing,",?33," $ESTACK:",$J($ES,3),"  SHOW=",SHOW
	Q
TR	;
	W !!,"In the TRAP, $ST:",$J($ST,3),"  SHOW=",SHOW," $ST(-1)=",$ST(-1)
	;W !,$ZE
	W !,$ECODE,! D SHW
	S $ETRAP="G UNW^test11" ;,$ECODE=",U1,"
	Q
UNW	W !,"In the Unwinder  $ESTACK:",$J($ES,3),"  SHOW=",SHOW," $ST(-1)=",$ST(-1)
	I $ESTACK>1 Q:'$Q  Q 0
	S $ECODE="" Q:'$Q  Q "ERR"
	Q
SHW	;
	F I=0:1:$ST(-1) W !,"$STACK(",I,")=",$ST(I),!,"ECODE=",$ST(I,"ECODE"),!,"PLACE=",$ST(I,"PLACE"),!,"MCODE=",$ST(I,"MCODE")
	Q
ZTRAP	;COME ON OLD ERROR TRAP
	W !,"IN OLD ERROR"
	Q
