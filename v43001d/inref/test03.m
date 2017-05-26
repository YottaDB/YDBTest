test03  ;
	; test error rethrow functionality if $ECODE is non-null at time of quit from an error frame
	;
        NEW $ETRAP SET $ETRAP="d ERROR1"
        d y1
        quit
y1      
        d START
        quit
START
        KILL A WRITE A
        QUIT
ERROR1
        set $ETRAP="d ERROR"
        set $ECODE=""
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
