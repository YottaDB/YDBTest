append	;Test the APPEND deviceparameter
	set file="append.dat"
	open file:(NEWVERSION)
	use file
	write "BLAH",!
	close file
	open file:(APPEND)
	use file
	write "MORE BLAH",!
	close file
	open file:(readonly)
	s totx=""
        for i=1:1 use file read x quit:$zeof  use $PRINCIPAL write !,i,?5,x s totx=totx_x
	use $PRINCIPAL
	w !
	i i=3,totx="BLAHMORE BLAH" write "PASS",!
	else  write "FAIL",! zwr
	close file
	q
