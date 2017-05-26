mergelv;
	FOR cnt=1:1:2 DO
     	. SET mvar="save"_cnt
	. do in4^lfill("set",5,1)
	. W "save in ",mvar,!
	. MERGE @mvar=afill
	. KILL afill
	. W "restore from ",mvar,!
	. MERGE afill=@mvar
	. KILL @mvar
	. do in4^lfill("ver",5,1)
	. do in4^lfill("set",5,1)
	. MERGE @mvar=bfill
	. KILL bfill
	. MERGE bfill=@mvar
	. do in4^lfill("ver",5,1)
	. do in4^lfill("kill",5,1)
	. KILL @mvar
	q
