c003032	; test eol handling of a botched sting literal
	;
	write !,"this is a bad string literal with a tab	in it,!
	set a="unclosed string
	set ^b="this is 	tab
	quit
