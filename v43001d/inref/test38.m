test38	;
	; test that $STACK(level) is correct in case of no errors
x       ;
        do y
        quit
y       ;
        x "do z"
        quit
z       ;
        set x=$$k^test38(2)
        quit
k(i)    ;
        write "$stack(-1) = ",$stack(-1),!
        for i=0:1:$stack(-1)  do
        .       write "$stack("_i_")            = ",$stack(i),!
        .       write "    $stack("_i_",""PLACE"") = ",$stack(i,"PLACE"),!
        .       write "    $stack("_i_",""MCODE"") = ",$stack(i,"MCODE"),!
        quit 3
