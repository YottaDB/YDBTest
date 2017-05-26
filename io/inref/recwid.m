recwid	;Test deviceparameters RECORDSIZE and WIDTH
	set file="recordwidth1.txt"
	do open^io(file,"NEWVERSION:RECORDSIZE=10")
	do use^io(file,"width=20")
	write "1234567890123 ",$x,!
	do close^io(file)
	open file
	use file
	do readfile^filop(file,0)
	close file
	set file="recordwidth2.txt"
	do open^io(file,"newversion:recordsize=20")
	do use^io(file,"width=10")
	write "1234567890123 ",$x,!
	do close^io(file)
	open file
	use file
	do readfile^filop(file,0)
	close file
	set file="recordwidth3.txt"
	do open^io(file,"newversion:recordsize=10")
	set unix=$ZVERSION'["VMS"
	if unix do use^io(file)
	if 'unix do use^io(file,"WIDTH=20")
	write "1234567890123 ",$x
	write "1234567890123 ",$x
	do close^io(file)
	open file
	use file
	do readfile^filop(file,0)
	close file
