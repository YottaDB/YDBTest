test30	;
	; Test that GOTO in error handler rethrows the error on a quit of that frame if $ECODE is still non-NULL
x	;
	set $etrap="goto etr"
	do y
	quit
y	;
	set x=1/0
	quit
etr	;
	write "in etr : $ecode = ",$ecode,!
	quit
