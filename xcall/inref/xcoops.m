	Do &hello	; no arguments
	Write !

	Set along=12345
	Write "passing ",along," to oops",!
	Do &oops(along)
	Write !

	Quit
