test02	;
	; test $STACK(-1) functionality
	;
	;
        NEW $ETRAP
        SET $ETRAP="d ERROR1"
        d START
        quit
START
        KILL A
        WRITE A
        QUIT
ERROR1
        set $ETRAP="d ERROR"
        d ERROR
        set x=1/0
        quit
ERROR
        write !,"$ecode     = ",$ecode
        write !,"$stack     = ",$stack
        write !,"$stack(-1) = ",$stack(-1)
        for index=0:1:$stack(-1)  do
        .       write !,"$stack("_index_",""ECODE"") = ",$j($stack(index,"ECODE"),16)
        .       write " :: $stack("_index_",""MCODE"") = ",$stack(index,"MCODE")
        write !
        quit

