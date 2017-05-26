zdform  ; ; ; test zdate_form
;
	New (act)
	If '$Data(act) New act Set act="W !,zdf,?5 zp @$zpos"
	Set cnt=0
	For zdf=$ZDATEFORM,'zdf Do
	. w $ZDate(58073),!
	. w $ZDate(58074),!
	. If "12/31/99"'=$ZDate(58073) Set cnt=cnt+1 Xecute act
	. If $Select(zdf:"01/01/2000",1:"01/01/00")'=$ZDate(58074) Set cnt=cnt+1 Xecute act
	. Set $ZDATEFORM='zdf
	;. View "zdate_form":'zdf
	Write !,$Select(cnt:"FAIL",1:"PASS")," from ",$Text(+0),!
	Quit
