	; Valid test cases to check recursive invocation of ZTRAP when set to 
	; entry references

MAIN	w "Testing Recursive Ztrap to find the sum",!
	set $ztrap="SUM",cntr=100,sum=0
	w "Sum of first ",cntr," numbers = "
        w 1/sum,!
        quit

SUM	;
	s sum=sum+cntr
	s cntr=cntr-1
	set:'cntr n=1
	s n=n+1
	w sum,!
        quit
