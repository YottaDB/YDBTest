unicodereadonly(encoding)
	;Test the READONLY deviceparameter
	set file="readonly.txt"
	set $ZTRAP="do error^unicodereadonly"
	do open^io(file,"NEWVERSION",encoding)
	use file
	write "ＰＱＲＳ",!
	use file:(REWIND)
	do readfile^filop(file,0)
	close file
	do open^io(file,"READONLY",encoding)
	use file
	write "ＰＱＲＳ",!
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

