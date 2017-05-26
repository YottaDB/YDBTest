stacktst	;
	; test of STACKCRIT and STACKOFLOW errors
	s x="x x"
	s $zt="s i=0 write ""$ZSTATUS="",$zstatus,! x x"
	x x
	quit
