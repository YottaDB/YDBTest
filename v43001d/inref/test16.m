test16	;
	; test error handling unwinding out of an active TSTART frame 
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
        quit
ecprint	;
	write "I am in ecprint",!
	write "$ecode = ",$ecode,!
	quit
