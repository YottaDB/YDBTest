TPATOMIC ; ; ; Test of transaction atomicity
	new (act)
	if '$d(act) new act set act="zshow"
	set ERR=0
	;
	set ITEM="Test of Transaction Rollback"
	;s t0=$zgetjpi(0,"CPUTIM")
	do in^tdbfill("S",0)
	;s t1=$zgetjpi(0,"CPUTIM")
	;w "data fill timing without TP :",t1-t0,!
	TSTART ()
	do in^tdbfill("K",0)
	TROLLBACK
	do in^tdbfill("V",0)
	;
	set ITEM="Test of Transaction Commit"
	set jmjoname="tpatomic1s"
	do ^job("in^tdbfill",1,"""""""S"""",1""")
	;
	TSTART ():SERIAL
	;s tp0=$zgetjpi(0,"CPUTIM")
	do in^tdbfill("S",0)
	;s tp1=$zgetjpi(0,"CPUTIM")
	;w "data fill timing with TP :",tp1-tp0,!
	TCOMMIT
	;s t0=$zgetjpi(0,"CPUTIM")
	do in^tdbfill("V",0)
	;s t1=$zgetjpi(0,"CPUTIM")
	;w "data fill timing without TP :",t1-t0,!
	;
	set jmjoname="tpatomic1k"
	do ^job("in^tdbfill",1,"""""""K"""",1""")
	;
	TSTART ():SERIAL
	;s tp0=$zgetjpi(0,"CPUTIM")
	do in^tdbfill("S",0)
	;s tp1=$zgetjpi(0,"CPUTIM")
	;w "data fill timing with TP :",tp1-tp0,!
	TCOMMIT
	;s t0=$zgetjpi(0,"CPUTIM")
	do in^tdbfill("V",0)
	;s t1=$zgetjpi(0,"CPUTIM")
	;w "data fill timing without TP :",t1-t0,!
	;
	set ITEM="Test of rollback when program fails to commit transaction"
	do in^tdbfill("S",1)
	TSTART ()
	do in^tdbfill("K",1)
	write !,$s(ERR:"FAIL",1:"PASS")," from ",$t(+0)
	halt  ;to force rollback
