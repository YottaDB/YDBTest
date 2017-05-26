test37	;
	; test of $STACK(level) and "MCODE", "PLACE" and "ECODE" aspects
x       ;
        set $etrap="do etr"
        x "do y"
        quit
y       ;
        w $$z^test37(2)
        quit
z(i)    ;
        do k
        quit
k       ;
        s x=1/0
        quit
etr     ;
        write "$stack(-1) = ",$stack(-1),!
        for i=0:1:$stack(-1)  do
        .       write "$stack("_i_") = ",$stack(i),!
        .       write "$stack("_i_",""ECODE"") = ",$stack(i,"ECODE"),!
        .       write "$stack("_i_",""PLACE"") = ",$stack(i,"PLACE"),!
        .       write "$stack("_i_",""MCODE"") = ",$stack(i,"MCODE"),!
        quit:$quit
