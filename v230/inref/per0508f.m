per0508f	;per0508 - zlink fails if many Do's
	;
	Write !,$TEXT(+0),?10,$TEXT(+1)
	Quit
 Do ^dummy001
 Do ^dummy002
 Do ^dummy003
 Do ^dummy004
 Do ^dummy005
 Do ^dummy006
