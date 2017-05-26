test05	;
	; test04, test05 and test06 test that explicit "quit" in $ETRAP or $ZTRAP works equally well as no quit
	; test04, test05 and test06 all should have the same output
	;
	set etr1="d y2"
	set etr2="d y3 quit"
        SET $ETRAP=etr1
        d y1
        quit
y1
        KILL A WRITE A
        QUIT
y2
        set $ETRAP=etr2
        set $ECODE=""
        set x=1/0
        quit
y3
        write !,"$ecode     = ",$ecode
        write !,"$stack     = ",$stack
        write !,"$stack(-1) = ",$stack(-1)
        for index=0:1:$stack(-1)  do
        .       write !,"$stack("_index_",""ECODE"") = ",$j($stack(index,"ECODE"),16)
        .       write " :: $stack("_index_",""MCODE"") = ",$stack(index,"MCODE")
        write !
        quit

