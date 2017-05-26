longrec; ; ; a routine to write long lines        
;        
	New (act)        
	If '$Data(act) Set act="W ! ZSH ""*"" W !"        
	Set cnt=0        
	New $ZTrap        
	Set $ZTrap="S cnt=cnt+1 X act G exit"        
	F i=32764:1:32767 s x=$j(i,i),dx=$x w x,!
Exit    Write !,$Select(cnt:"FAIL",1:"PASS")," from ",$Text(+0)        
	Quit
