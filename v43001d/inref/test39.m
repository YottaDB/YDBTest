test39	;
	; test that $STACK(level) is not frozen in case of nested error under first ECODE
x       ;
        set $etrap="do etr"
        set count=0
        do y
        quit
y       ;
        do z
        quit
z       ;
        set x=1/0
        quit
etr     ;
        set count=count+1
	do ecprint
        if count=1 do p
        quit
p       ;
        quit 1
ecprint ;
        write !,"$ecode     = ",$ecode
        write !,"$stack     = ",$stack
        write !,"$stack(-1) = ",$stack(-1)
        for index=0:1:$stack(-1)  do
        .       write !,"$stack("_index_",""ECODE"") = ",$j($stack(index,"ECODE"),16)
        .       write " :: $stack("_index_",""MCODE"") = ",$stack(index,"MCODE")
        write !
        quit
