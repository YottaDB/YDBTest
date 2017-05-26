xy	;Test the deviceparameter LENGTH (and $X and $Y)
	set file="testxy.txt"
	do open^io(file,"NEWVERSION:BIGRECORD:RECORDSIZE=1048576")
	do use^io(file)
	write "NEWVERSION:BIGRECORD:RECORDSIZE=1048576",!
	do longlins
	do use^io(file,"LENGTH=4")
	write "LENGTH:4",!
	for i=1:1:15 write $J("_",i),",$X:",$X,",$Y:",$Y,!
	do use^io(file,"LENGTH=50:WIDTH=30:WRAP")
	write "LENGTH:50,WIDTH=30:WRAP",!
	for i=1:1:52 write $J("_",i#31),",$X:",$X,",$Y:",$Y,!
	do use^io(file,"WIDTH=32767")
	write "WIDTH=32767",!
	write "long line:",$$^longstr(31*1024),$X,!
	write "loong line:",$$^longstr(32*1024),$X,!
	do use^io(file,"WIDTH=1048576")
	write "WIDTH=1048576",!
	do longlins
	do close^io(file)
	do open^io(file,"REWIND:BIGRECORD:RECORDSIZE=1048576")
	do readfile^filop(file,0)
	do close^io(file)
	write "Test that LENGTH=0 does not reset $Y",!
	set file2="testxylong.txt"
	do open^io(file2,"NEWVERSION:RECORDSIZE=6")
	do use^io(file2,"LENGTH=0")
	write $$^longstr(1024*1024),!,$Y,!
	do close^io(file2)
	; now check
	do open^io(file2,"REWIND:RECORDSIZE=7") ; 7: to accomodate the newline
	for i=1:1 use file2 read line quit:$ZEOF  set prevline=line
	use $PRINCIPAL
	; 174763= 1 + 1024*1024/6
	set fail=0
	if 174763'=prevline set fail=1
	if i'=(prevline+2) set fail=1
	if fail write "TEST-E-FAIL, wrong $Y value: ",prevline,", or line count: ",i,!
	else  write "PASS, LENGTH=0 does not reset $Y",!
	do close^io(file2)
	quit
longlins ;
	write "looong line:",$$^longstr(33*1024),$X,!
	write "loooong line:",$$^longstr(1024*1024-20),$X,!
	write "loooong line:",$$^longstr(1024*1024),$X,!
	quit

