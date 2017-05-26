bigectst; ; ; test that a hugh $ECODE does not cause a problem
	;
	New (act)
	If '$Data(act) New act Set act="ZP @ZPOS"
	Set cnt=0
	Kill b
	Set $ZT="Q"
	For I=1:1:32768 Do
	. Set a=b
	Set $ETRAP="S cnt=cnt+1 X act G exit"
	If 32767<$Length($ECode) Set cnt=cnt+1 Xecute act
	Set a=$ECode_""
	Write !,$ECode
exit	Set $ETRAP=""
	Write !,$Select(cnt:"FAIL",1:"PASS")," from ",$Text(+0)
	Quit
