stacktst1	;
	; test of STACKCRIT and STACKOFLOW errors
	;
	s x="x x"
	s $et="s $ec="""" write ""$ZSTATUS="",$zstatus,! x x"
	x x
	quit
