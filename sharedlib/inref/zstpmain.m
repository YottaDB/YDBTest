zstpmain	;
	set longname90123456789012345678901=0
	f i=1:1:maxline  do
	. do increment^zstpmain	
	q

increment;
	set longname90123456789012345678901=longname90123456789012345678901+1
	write longname90123456789012345678901,!
	quit
