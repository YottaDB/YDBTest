test18	;
	; test of starting a TP transaction within an error handler and quitting without TCOMMIT
x       ;
        set $et="do ecprint"
        do y
        quit
y       ;
        new $et
        set $et="do etr"
        s x=1/0
        quit
etr     ;
        write "I am in etr",!
        tstart ():serial	; buggy TSTART
        quit
ecprint ;
        write "I am in ecprint",!
        write "$ecode = ",$ecode,!
        quit
