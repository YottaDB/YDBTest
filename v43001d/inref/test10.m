test10	;
	; Test that the first error does not get lost because of overlaying errors.
	;
x0      ;
        set $ecode=""
        set count=0
        set $etrap="do etr"
        do x1
        quit
x1      ;
        do x2
        quit
x2      ;
        do x3
        quit
x3      ;
        set x=1/0
        quit
etr     ;
        do yprint
        set count=count+1
        if count=1 kill a write a
        if count=2 quit 1
        if count=3 set x=1 merge x(1)=x
        if count=4 do y4
        quit
y3      ;
        s x=1
        merge x(1)=x
        quit
y4      ;
        write $r(-2)
        quit
yprint  ;
        write !,"$ecode     = ",$ecode
        write !,"$stack     = ",$stack
        write !,"$stack(-1) = ",$stack(-1)
        for index=0:1:$stack(-1)  do
        .       write !,"          $stack("_index_") = ",$j($stack(index),10)
        .       write !,"$stack("_index_",""ECODE"") = ",$j($stack(index,"ECODE"),16)
        .       write !,"$stack("_index_",""PLACE"") = ",$j($stack(index,"PLACE"),10)
        .       write !,"$stack("_index_",""MCODE"") = ",$j($stack(index,"MCODE"),20)
        write !
        quit
