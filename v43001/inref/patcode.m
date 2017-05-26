C000150 ; ; ; test pattern codes        
;        
	New (act)        
	If '$Data(act) Set act="W ! ZP $ZPOS W ! ZWR W !"        
	Set cnt=0
	New $ZTrap        
	Set $ZTrap="D err"        
	Set top=90        
	Set i=64
L0      If top>i Set i=i+1,x=cnt?@$Char(57,i) Goto L0
	Set top=122        
	Set i=96
L1      If top>i Set i=i+1,x=cnt?@$Char(57,i) Goto L1        
	Write !,$Select(cnt:"FAIL",1:"PASS")," from ",$Text(+0)        
	Quit
err     Set error=$Piece($Piece($ZStatus,"-PAT",2),", ")        
	Set error=$Select("CODE"=error:"BbDdFfGgHhIiJjKkMmOoQqRrSsTt","CLASS"=error:"VvWwXxYyZz",1:"")        
	If error'[$Char(i) Set cnt=cnt+1 Xecute act
