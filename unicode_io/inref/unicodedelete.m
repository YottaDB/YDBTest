unicodedelete(encoding)
	;Test the DELETE deviceparameter
	SET $ZTRAP="GOTO errorAndCont^errorAndCont"
	set verbose=1
	set file="delete"_encoding_".txt"
	set s1=$ZSEARCH(file)
	do open^io(file,"NEWVERSION",encoding)
	use file
	write "ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗ",!
	write "我能吞下玻璃而傷身體。",!
	set s2=$ZSEARCH(file)
	close file:(delete)
	use $PRINCIPAL
	write "s2=",s2,!
	set s3=$ZSEARCH(file)
	if ""=s1,""=s3,""'=s2 write "PASS, file is deleted",!
	else  write "FAIL",! zwr
	q
