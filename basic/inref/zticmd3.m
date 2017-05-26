	; Test cases for ZTRAP containing a command with syntax errors

TST1	w "Testing syntax error..."
	s $zt="zw" ;sytax error - indented to be zwrite
	do SUB1 q
TST2	w "Testing quit as label..." 	
	s $zt="quit"
	do SUB1 q
TST3	w "Testing syntax error in set command..."	
	s $zt="set x =1"
	do SUB1 q
TST4	w "Testing indirect arg with syntax error..."	
	s ind="x= 1"
 	s $zt="set @ind"	
	do SUB1 q 

SUB1	w "zlevel = ",$zlevel,!
	kill x   
	w x,! ; bad line
	q
zw	w "done",! q
quit	w "should not reach",! q
set	w "done",! q
