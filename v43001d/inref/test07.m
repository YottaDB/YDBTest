test07	;
	; test that nested errors are shown in $STACK and ecode contains a concatentation of all errors until now
	;
x       ;
        s count=0
        set $etrap="do error"
        do y
        quit
y       ;
        do z
        quit
z       ;
        kill x write x
        quit
error   ;
        s count=count+1
        write !,"$ecode     = ",$ecode
        write !,"$stack     = ",$stack
        write !,"$stack(-1) = ",$stack(-1)
        for index=0:1:$stack(-1)  do
        .       write !,"$stack("_index_",""ECODE"") = ",$j($stack(index,"ECODE"),16)
        .       write " :: $stack("_index_",""MCODE"") = ",$stack(index,"MCODE")
        write !
        if count=1  write 1/0
        if count>1  quit 1
        quit
