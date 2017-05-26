test13	;
	; Test the following scenario.
	; 	a) primary error happens with $ETRAP enabled
	; 	b) the error handler goes into a frame that has $ZTRAP enabled
	; 	c) an error occurs there
	; 	The expected behaviour is that the second error is considered a nested error
	; 		and that we unwind out of frames successively until we unwind out of
	; 		the one which had the primary error.
x	;
	set $etrap="do eprint"
	do y
	write "after all error handling",!
	quit
y	;
	s $etrap="do ztr"
	write 1/0
	quit
ztr	;
	write "---> In ztr",!
	w "$ecode = ",$ecode,!
	s $ztrap="do ztr1"
	write x,!
	quit
ztr1	;
	write "---> In ztr1",!
	w "$ecode = ",$ecode,!
	write "This point should not be reached",!
	set x=1
	quit
eprint	;
	write "---> In eprint",!
	write "$ecode = ",$ecode,!
	quit
