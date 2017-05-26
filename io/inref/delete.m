delete	;Test the DELETE deviceparameter
	set file="delete.txt"
	set s1=$ZSEARCH(file)
	open file:(NEWVERSION)
	use file
	write "BLAH",!
	set s2=$ZSEARCH(file)
	close file:(delete)
	use $PRINCIPAL
	set s3=$ZSEARCH(file)
	if ""=s1,""=s3,""'=s2 write "PASS, file is deleted",!
	else  write "FAIL",! zwr
	q
