; Verify zprev works with spanning nodes
; This scripts is called from basic.csh

zprev
	set span=$justify(" ",2500)
	set ^x("")=span
	set ^x("",100)=span
	set ^x(1)=span
	set ^x("a")=span
	set ^x("b")=1
	if $zprevious(^x("",100))'="" write "FAILED 1",!
	if $zprevious(^x("c"))'="b" write "FAILED 2",!
	if $zprevious(^x("",100))'="" write "FAILED 3",!
	if $zprevious(^x(3))'="1" write "FAILED 4",!
	quit
