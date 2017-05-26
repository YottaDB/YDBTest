unicodelength(encoding)
	; LENGTH - test that $Y never reset if LENGTH=0, also test some other LENGTH values
	set verbose=1
	set file=encoding_"_length0.txt"
	do open^io(file,"NEWVERSION",encoding)
	do use^io(file,"LENGTH=0")
	do test
	set file=encoding_"_length1.txt"
	do open^io(file,"NEWVERSION",encoding)
	do use^io(file,"LENGTH=1")
	do test
	set file=encoding_"_length100.txt"
	do open^io(file,"NEWVERSION",encoding)
	do use^io(file,"LENGTH=100")
	do test
	set file=encoding_"_length505.txt"
	do open^io(file,"NEWVERSION",encoding)
	do use^io(file,"LENGTH=505")
	do test
	quit
test	;
	for i=1:1:1500 write "$Y is:",$Y,!
	close file
	if (($zversion["OS390")&("M"'=encoding)) zsystem "chtag -tc ISO8859-1 "_file
	do ^tail(-10,file)
	quit
