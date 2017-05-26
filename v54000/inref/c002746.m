C002746	;
	; C9F07-002746 $INCR on an undefined global does not force alphanumeric string to numeric
	;
	set b="2two",$ecode="",$etrap="zshow ""*"" halt"
	kill ^a
	if $increment(^a,b),b'=+b,^a=+^a write !,"PASS"
	if $increment(^a,"2two"),^a=+^a write !,"PASS"
	else  write "FAIL"
	write " from ",$text(+0)
	quit
