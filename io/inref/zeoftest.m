;;;To test $ZEOF maintenance if there is no input device
;;;
zeoftest ;
	set file="file1.txt"
	open file
	write file," $ZEOF:",$ZEOF,!
	if $ZEOF write "TEST-E-FAIL, it is not supposed to be the end of the file!",!
	if '$ZEOF use file read line use $PRINCIPAL write "Was able to read from the file:",!,line,!
	quit
