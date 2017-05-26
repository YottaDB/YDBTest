	;Testing ZTRAP with indirect entryref arguments.
	;Format : ZTRAP @lab+@off^@module

INDIRECTSUBROUTINE1	w "Testing Ztrap @Label..."
	set $ztrap="@lab",lab="INDIRECTSUBROUTINE2"
	kill x
        w x,!
        quit

INDIRECTSUBROUTINE2    w "done(IND2)",!
	w "Testing Ztrap @Label+offest..."
        set $ztrap="@lab+off",lab="INDIRECTSUBROUTINE3",off=1
        kill x
        w x,!
        quit

INDIRECTSUBROUTINE3	w "done(IND3)",! goto INDIRECTSUBROUTINE3+2
        w "done(IND3+1)",!
	do INDIRECTSUBROUTINE4
    	w "Testing Ztrap @Label+@module..."
        set $ztrap="@lab^@mod",lab="labelinanothermoduleforztrap",mod="ztleaf" 
        kill x
        w x,! 
	quit

INDIRECTSUBROUTINE4	w "Testing Ztrap @Label+offset+@module..."
        set $ztrap="@lab+off^@mod",lab="labelinanothermoduleforztrap",off=1,mod="ztleaf"
        kill x
        w x,! 
        quit
