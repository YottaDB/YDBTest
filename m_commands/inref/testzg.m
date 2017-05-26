tzg(ll)	;
	do @ll
	quit
lc	;
	set c="1:b2345678^routinex"
	zgoto @c
	quit
ld	;
	zgoto 1:b2345678^routinex
	quit
b2345678 ;
	write "this is b2345678 in tzg",!
	quit
