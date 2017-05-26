	; Test case for ZTRAP containing a valid DO command.
	; and test for indirect args too.

MAIN	w "This is main function",!
	s $zt="do ERR"
     	s (a,b)=0
	s a=a+10,b=b+15 
	kill x
	w x,! 
 	w "value of a = ",a,!
 	w "value of b = ",b,!
 	w "value of x(a+b) = ",x,!
	;testing indirect arg to ztrap
	s ind="x=a*b"
	s $zt="set @ind"
	kill x
	w x,!
 	w "value of a = ",a,!
 	w "value of b = ",b,!
 	w "value of x(a*b) = ",x,!
	quit

ERR	w !,"error handler",!
	s x=a+b
	s $zt="Break"
	quit

