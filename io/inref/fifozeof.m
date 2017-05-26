fifozeof
	set ^readzready=0
	set ^writezready=0
	; open a pipe just to make sure jobbed off processes can close without assert
	set p="tpipe"
	open p:(comm="cat")::"pipe"
	job ^fifowrite
	job ^fiforead
	quit
