test26	;
	; test invoking a $$ function and causing an error there. 
	; Have a GOTO in $ETRAP to code that in turn does a QUIT @x (where x = "y" and y = 1) 
	;	and see that it triggers error processing at lower level.
x       ;
        set $et="goto ecprint"
        do y
        quit
y       ;
        new $et
        set $et="goto etr"
        s x=$$k^test26(1)
        quit
k(i)    ;
        s x=1/0
        quit
etr     ;
        s y=1
        s x="y"
        quit @x
ecprint ;
        write "$stack(-1) = ",$stack(-1),!
	write "$ecode     = ",$ecode,!
        for i=0:1:$stack(-1)  do
        .       write "$stack("_i_") = ",$stack(i),!
        .       write "$stack("_i_",""ECODE"") = ",$stack(i,"ECODE"),!
        .       write "$stack("_i_",""PLACE"") = ",$stack(i,"PLACE"),!
        .       write "$stack("_i_",""MCODE"") = ",$stack(i,"MCODE"),!
        quit
