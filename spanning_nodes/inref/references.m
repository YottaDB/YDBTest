; Verify Naked/Extended references and $reference works fine with spanning nodes.
; This script is called from basic.csh

references
	write "Naked ref. test",!
	set ^nakedgbl("")="BEGIN0"_$justify(" ",2500)_"END0"
	set ^nakedgbl(1)="BEGIN1"_$justify(" ",2500)_"END1"
	set ^nakedgbl(2)="BEGIN2"_$justify(" ",2500)_"END2"
	write ^(""),!
	write ^(1),!
	write $order(^(1)),!
	write ^(""),!
	write $query(^(1)),!
	write ^(""),!
	write "Extended ref. test",!
	write ^["mumps.gld"]nakedgbl(1),!
	if $reference'="^|""mumps.gld""|nakedgbl(1)" write "$reference does not work properly",!
	quit
