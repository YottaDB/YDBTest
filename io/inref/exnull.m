; This tests the cases where no COMMAND parameter is entered and COMMAND, SHELL, and STDERR parameters are null
exnull
	set p="test"
	OPEN p:(shell="/bin/sh":command="":stderr="e1":exception="g BADOPEN0")::"pipe"
	QUIT 

BADOPEN0
	do WRITEERR("BADOPEN0 error")
	OPEN p:(shell="/bin/sh":stderr="e1":exception="g BADOPEN1")::"pipe"
	QUIT 

BADOPEN1
	do WRITEERR("BADOPEN1 error")
	OPEN p:(shell="":command="pwd":stderr="e1":exception="g BADOPEN2")::"pipe"
	QUIT 

BADOPEN2
	do WRITEERR("BADOPEN2 error")
	OPEN p:(shell="/bin/sh":command="pwd":stderr="":exception="g BADOPEN3")::"pipe"
	QUIT 

BADOPEN3
	do WRITEERR("BADOPEN3 error")
	QUIT 

WRITEERR(badstring)
	write !,badstring,!
	w $zstatus,!
	zshow "d"
	QUIT
