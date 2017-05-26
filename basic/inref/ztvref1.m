	; Valid test cases to check functionality of ZTRAP when set to entry 
	; references
     	; format of entryref : label+offset^module.

SUBROUTINE1	w "Testing Ztrap Label..."
	set $ztrap="SUBROUTINE2" 
	kill x
        w x,!
        quit

SUBROUTINE2    w "done(SUB2)",!
 	w "Testing Ztrap Lable+offset..."
        set $ztrap="SUBROUTINE3+1"
        kill x
        w x,!
        quit

SUBROUTINE3	w "begin SUB3",! goto SUBROUTINE3+2
        w "done(SUB3+1)",!
	do SUBROUTINE4
    	w "Testing Ztrap Label+module..."
        set $ztrap="labelinanothermoduleforztrap^ztleaf"
        kill x
        w x,!
 	quit

SUBROUTINE4	w "Testing Ztrap Label+offset+module..."
        set $ztrap="labelinanothermoduleforztrap+1^ztleaf" 
        kill x
        w x,! 
        quit
