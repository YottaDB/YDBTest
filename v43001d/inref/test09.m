test09	;
	; Test that ECODEs do not get added for rethrown errors.
	;
x       ;
        set $etrap="do etr"
        do y
        quit
y       ;
        do z
        quit
z       ;
        set x=1/0
        quit
etr     ;
        w $ecode,!
        quit
