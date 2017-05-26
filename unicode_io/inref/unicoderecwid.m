unicoderecwid(encoding)	
	;Test deviceparameters RECORDSIZE and WIDTH
	set verbose=1
	set file=encoding_"_recordwidth1.txt"
	do open^io(file,"NEWVERSION:RECORDSIZE=10",encoding)
	do use^io(file,"width=20")
	write "１２３４５６７８９０１２３",$x,!
	do close^io(file)
	;
	open file:(CHSET=encoding)
	use file
	do readfile^filop(file,0)
	close file
	;
	;
	set file=encoding_"_recordwidth2.txt"
	do open^io(file,"newversion:recordsize=20",encoding)
	do use^io(file,"width=10")
	write "１２３４５６７８９０１２３",$x,!
	do close^io(file)
	;
	open file:(CHSET=encoding)
	use file
	do readfile^filop(file,0)
	close file
	;
	;
	set file=encoding_"_recordwidth3.txt"
	do open^io(file,"newversion:recordsize=10",encoding)
	do use^io(file)
	write "１２３４５６７８９０１２３",$x
	write "１２３４５６７８９０１２３",$x
	do close^io(file)
	;
	open file:(CHSET=encoding)
	use file
	do readfile^filop(file,0)
	close file
	quit
