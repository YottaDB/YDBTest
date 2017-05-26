test27	;
	; have a QUIT 1 in $ETRAP as part of an error in a $$ function. 
	; See if the error is retriggered at lower levels since $ecode is still non-NULL.
x       ;
        set $etrap="write ""I am in etr"",!  quit 1"
        do y
        quit
y       ;
        set x=$$z^test27(1)
        quit
z(a)    ;
        s x=1/0
        quit 1
