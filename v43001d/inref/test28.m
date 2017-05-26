test28	;
	; a $ETRAP which has a GOTO in it and that resets $ECODE to NULL and then retriggers another error.
x       ;
        set $etrap="do ecprint"
        do y
        quit
y       ;
        new $etrap
        set $etrap="goto etr"
        set x=1/0
        quit
etr     ;
        write "I am in etr",!
        write "$ecode = ",$ecode,!
        set $ecode=""
        quit 1
        quit
ecprint ;
        write "$stack(-1) = ",$stack(-1),!
        write "$ecode = ",$ecode,!
        quit
