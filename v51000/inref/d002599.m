d002599 ;
	; D9G03-002599 GTM does not detect (and stop) external reference to second replicated instance
        ;
	quit
mumpsfirst;
	set ^|"mumps.gld"|nonrepl=1
	set ^|"mumps.gld"|repl=2
	set ^|"other.gld"|nonrepl=3
	set ^|"other.gld"|repl=4	; should issue REPLINSTMISMTCH error
        quit

otherfirst;
	set ^|"other.gld"|nonrepl=9991
	set ^|"other.gld"|repl=9992
	kill ^|"other.gld"|repl
	kill ^|"mumps.gld"|nonrepl
	kill ^|"mumps.gld"|repl		; should issue REPLINSTMISMTCH error
	quit
