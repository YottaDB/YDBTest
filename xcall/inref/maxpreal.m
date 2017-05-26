maxpreal ;
	;
	Set achrpp="C-style string"
	Do &alloc1mb(.achrpp)
	Write "Now length is : ",$LENGTH(achrpp),!
	q
