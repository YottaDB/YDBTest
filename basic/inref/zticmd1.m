	; Invalid ZTRAP value with null string
	; This test no longer produces any error output
MAIN	w !,"This is main function"
	s $ztrap=""
	kill x
	w x,!
	w "this is not displayed",!
	quit

