test40	;
	; test that $STACK(level) info is not stored after level 255 even though $stack(-1) might be greater than 255
	; in this example below there should be some $STACK(level,"MCODE") displayed with an empty line.
	; this is because the error happened at that level and we do not store that level information
	;	though we get non-empty lines for higher level "MCODE" because we get it from the current M-stack
x       ;
        set count=0
        set $etrap="do etr"
        do y
        quit
y       ;
        set count=count+1
        if count>256 s x=1/0
        do y
        quit
etr     ;
        do etr1
        quit
etr1    ;
        set count=count+1
        if count>280 do etr2
        else  do etr1
        quit
etr2    ;
        write !,"$ecode     = ",$ecode
        write !,"$stack     = ",$stack
        write !,"$stack(-1) = ",$stack(-1)
        for index=0:1:$stack(-1)  do
        .       write !,"$stack("_index_",""ECODE"") = ",$j($stack(index,"ECODE"),16)
        .       write " :: $stack("_index_",""MCODE"") = ",$stack(index,"MCODE")
        write !
        set $ecode=""
        quit
