	;Testing ZTRAP with indirect entryref arguments.
	;Format : ZTRAP @lab+@off^@module

IND1	w "Testing Ztrap @Label..."
	set $ztrap="@lab",lab="IND2"
	kill x
        w x,!
        quit

IND2    w "done(IND2)",!
	w "Testing Ztrap @Label+offest..."
        set $ztrap="@lab+off",lab="IND3",off=1
        kill x
        w x,!
        quit

IND3	w "done(IND3)",! goto IND3+2
        w "done(IND3+1)",!
	do IND4
    	w "Testing Ztrap @Label+@module..."
        set $ztrap="@lab^@mod",lab="lab",mod="ztleaf" 
        kill x
        w x,! 
	quit

IND4	w "Testing Ztrap @Label+offset+@module..."
        set $ztrap="@lab+off^@mod",lab="lab",off=1,mod="ztleaf"
        kill x
        w x,! 
        quit
