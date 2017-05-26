readonly ;Test the READONLY deviceparameter
	set file="readonly.txt"
	set $ZTRAP="do error^readonly"
	open file:(NEWVERSION)
	use file
	write "BLAH",!
	use file:(REWIND)
	do readfile^filop(file,0)
	close file
	open file:(READONLY)
	use file
	write "BLAH",!
	close file
	write "FAIL",! zwr
	quit
error	;
	new $ZTRAP
	use $PRINCIPAL
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	write "In ZTRAP",!
	write $ZSTATUS,!
	close file
	write "The file, again:",!
	open file
	use file:(REWIND)
	do readfile^filop(file,0)
	use $PRINCIPAL
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	halt

