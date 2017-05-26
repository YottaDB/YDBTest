length	; LENGTH - test that $Y never reset if LENGTH=0, also test some other LENGTH values
	set unix=$ZVERSION'["VMS"
	set file="length0.txt"
	do open^io(file,"NEWVERSION")
	do use^io(file,"LENGTH=0")
	do test
	set file="length1.txt"
	do open^io(file,"NEWVERSION")
	do use^io(file,"LENGTH=1")
	do test
	set file="length100.txt"
	do open^io(file,"NEWVERSION")
	do use^io(file,"LENGTH=100")
	do test
	set file="length505.txt"
	do open^io(file,"NEWVERSION")
	do use^io(file,"LENGTH=505")
	do test
	quit
test	;
	for i=1:1:1500 write "$Y is:",$Y,!
	close file
	if unix zsystem "tail "_file
	if 'unix zsystem "type /tail=10 "_file
	quit
