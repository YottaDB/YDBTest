	; Test case for Invalid ZTRAP with DO handler containing an error 
	; statement
	; Stack overflow expected with handler being called repeatedly.

MAIN	w "This is main function",!
	s $zt="do ERR"
     	s (a,b)=0
	s a=a+1,b=b+1 
	kill x
	w x,! ;bad line
 	w "value of a = ",a,!
 	w "value of b = ",b,!
 	w "value of x = ",x,!
	quit

ERR	if $zversion'["VMS" zwrite:$zstatus["STACKCRIT" $zstatus
	s x=x+b ;bad line
	s $zt="Break"
	quit

