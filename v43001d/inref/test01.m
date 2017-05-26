test01	;
	; test new $ESTACK across zgotos and nested news 
	;
        set $etrap="do error"
        write $estack,!
        do x1
        write $estack,!
        write "I am in x1",!
        quit
x1      ;
        do x2
        write $estack,!
        write "I am in x2",!
        quit
x2      ;
        write $estack,!
        new $estack
        write $estack,!
        write 1/0
        zgoto 1
        quit
error   ;
        set $ecode=""
        set $etrap="do error1"
        write $estack,!
        do errorh
        quit
errorh  ;
        write 1/0
        quit
error1  ;
        set $ecode=""
        set $etrap=""
        write $estack,!
        quit
