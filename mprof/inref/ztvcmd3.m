	; Test case for ZTRAP containing a valid QUIT/HALT command.

MAIN	w "This is main function",!
	s $zt="QUIT"
	w "Before SUB1",!
	do SUB1
	w "After SUB1",!
	s $zt="HALT"
	w "Before SUB2",!
	do SUB2
	w "After SUB2",!
	
SUB1	w "this is SUB1",!
	w "zlevel = ",$zlevel,!
	kill x 
	w x,! ; bad line
	w "should not reach this line",!
	q
SUB2	w "this is SUB2",!
	s a=1,b=1 
	kill x 
	w x,! ;bad line
 	w "skipped by HALT",!
	q

