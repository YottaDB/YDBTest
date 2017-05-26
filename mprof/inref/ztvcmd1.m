	; Test case for ZTRAP containing a valid ZGOTO command.

MAIN	w "This is main function",!
	s $zt="zgoto 2:EXIT"
	do SUB1
	w "skipped by zgoto",!
	quit

SUB1	w "this is SUB1",!
	do SUB2
	w "this is skipped by zgoto",!
	quit

SUB2	w "this is SUB2",!
	kill x
	w x,!
	w "this is not displayed",!
	quit

EXIT	w "exiting main function",!
	w "stack level: ",$zlevel,!
	s $zt="Break"
	quit

