tpresno	; ; ; TREstart a non-restartable TRANSACTION
	;
	New (act)
	If '$data(act) New act Set act="ZP @$ZPOS"
	Set cnt=0
	New $ZTrap
	Set $ZTrap="S $ZT="""",cnt=cnt-1 TRO:$TL  ZG "_$ZL_":exit"
	TStart
	Set cnt=cnt+1
	If 1=cnt D
	. Set ^a=1
	. TREstart
	. Set cnt=cnt+1 Xecute act
	TROllback
exit	Write !,$Select(cnt:"FAIL",1:"PASS")," from ",$Text(+0),!
	Quit
