dsystem ; ; ; test $system        
;       New (act)        
	If '$Data(act) New act Set act="W !,gtmsid,! ZP @$ZPOS"        
	Set cnt=0
	Set gtmsid=$ZTRNLNM("gtm_sysid")        
	If "47,"'=$Extract($SYstem,1,3) set cnt=cnt+1 Xecute act        
	If $Select($Length(gtmsid):gtmsid,1:"gtm_sysid")'=$Extract($system,4,9999) set cnt=cnt+1 Xecute act        
	Write !,$Select(cnt:"FAIL",1:"PASS")," from ",$Text(+0),!       
	Quit
