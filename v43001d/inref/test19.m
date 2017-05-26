test19	;
	; Try starting a TP transaction within an error handler while TP is already in effect and quitting without TCOMMIT
	;
x       ;
        set $et="do ecprint"
        do y
        quit
y       ;
        new $et
        set $et="do etr"
	tstart ():serial
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
