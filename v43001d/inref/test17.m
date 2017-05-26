test17	;
	; test nested error within active TP.  In the below example, frame "y" has an open TP transaction 
	; when the primary error occurs and frame "etr" has a nested error
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
	quit 1
        quit
ecprint	;
	write "I am in ecprint",!
	write "$ecode = ",$ecode,!
	quit
