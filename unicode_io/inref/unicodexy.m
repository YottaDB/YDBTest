unicodexy(encoding)		
	;Test the deviceparameter LENGTH (and $X and $Y)
	set verbose=1
	set file=encoding_"_testxy.txt"
	do open^io(file,"NEWVERSION:BIGRECORD:RECORDSIZE=1048576",encoding)
	do use^io(file)
	write "NEWVERSION:BIGRECORD:RECORDSIZE=1048576",!
	do longlines
	do use^io(file,"LENGTH=4")
	write "LENGTH:4",!
	for i=1:1:15 write $J("_",i),",$X:",$X,",$Y:",$Y,!
	do use^io(file,"LENGTH=50:WIDTH=30:WRAP")
	write "LENGTH:50,WIDTH=30:WRAP",!
	for i=1:1:52 write $J("_",i#31),",$X:",$X,",$Y:",$Y,!
	do use^io(file,"WIDTH=32767")
	write "WIDTH=32767",!
	write "long line:",ulongstr31,$X,!
	write "loong line:",ulongstr32,$X,!
	do use^io(file,"WIDTH=1048576")
	write "WIDTH=1048576",!
	do longlines
	do close^io(file)
	;
	do open^io(file,"REWIND:BIGRECORD:RECORDSIZE=1048576",encoding)
	do readfile^filop(file,0)
	do close^io(file)
	;
	; there is an open bug "RECORDSIZE and multibyte chars"
	; disable the below test, if CHSET '= M
	if ("M"'=encoding) quit
	write "Test that LENGTH=0 does not reset $Y",!
	set file2=encoding_"_testxylong.txt"
	do open^io(file2,"NEWVERSION:RECORDSIZE=6",encoding)
	do use^io(file2,"LENGTH=0")
	write ulongstr1024a,!,$Y,!
	do close^io(file2)
	;
	; now check
	do open^io(file2,"REWIND:RECORDSIZE=7",encoding) ; 7: to accomodate the newline
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
longlines ;
	write "looong line:",ulongstr33,$X,!
	write "loooong line:",ulongstr1024b,$X,!
	write "loooong line:",ulongstr1024a,$X,!
	quit

