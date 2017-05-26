	; Valid test cases to check functionality of ZTRAP when set to entry 
	; references
     	; format of entryref : label+offset^module.

SUB1	w "Testing Ztrap Label..."
	set $ztrap="SUB2" 
	kill x
        w x,!
        quit

SUB2    w "done(SUB2)",!
 	w "Testing Ztrap Lable+offset..."
        set $ztrap="SUB3+1"
        kill x
        w x,!
        quit

SUB3	w "begin SUB3",! goto SUB3+2
        w "done(SUB3+1)",!
	do SUB4
    	w "Testing Ztrap Label+module..."
        set $ztrap="lab^ztleaf"
        kill x
        w x,!
 	quit

SUB4	w "Testing Ztrap Label+offset+module..."
        set $ztrap="lab+1^ztleaf" 
        kill x
        w x,! 
        quit
