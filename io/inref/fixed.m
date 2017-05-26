fixed	; Test the FIXED deviceparameter
	set file="fixed1.txt"
	do open^io(file,"NEWVERSION:FIXED:RECORDSIZE=10")
	do use^io(file,"WIDTH=20")
	do wrt
	use $PRINCIPAL
	write ?13 for i=1:1:8 write "1234567890"
	write !
	set file="fixed2.txt"
	do open^io(file,"NEWVERSION:FIXED:RECORDSIZE=12")
	do use^io(file)
	do wrt
	use $PRINCIPAL
	write ?13 for i=1:1:5 write "123456789012"
	write !
	set file="fixed3.txt"
	do open^io(file,"NEWVERSION:FIXED:RECORDSIZE=15")
	do use^io(file,"WIDTH=10")	; VMS will error out
	do wrt
	use $PRINCIPAL
	write ?13 for i=1:1:5 write "1234567890"
	write !
	quit
wrt	;
	write "123",!
	write "123",!
	write "123",!
	write "blah blah blah",!
	write "123",!
	close file
	open file
	use file
	do readfile^filop(file,0)
	quit
