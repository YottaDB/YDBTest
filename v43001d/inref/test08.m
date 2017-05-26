test08	;
	; test that "set $ecode" within a ZTRAP active frame does trigger $ZTRAP indefinitely.
x       ;
        set count=0
        set $ztrap="do ztr"
        set $ecode=""  set $ecode=",M9,Z150373210,"
        quit
ztr     ;
        write "I am in ZTRAP",!
        write $ecode,!
        set count=count+1
        if count>5 set $ztrap="goto ztr"
        quit
