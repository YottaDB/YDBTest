overflow ;
        ; A part of mprof/D9L03002804 test. Generates M stack overflow conditions and ensures that 
	; M-profiling does not overflow sooner; verifies that disabling and reenabling tracing upon
	; reaching large stack levels does not cause problems.
	;
	kill ^trace
        set $ztrap="do err"
        set x=0
	;
	; recurse small and print ^trace
	view "trace":1:"^trace"
	do recursesmall
	do post
	view "trace":0:"^trace"
	zwrite ^trace
	kill ^trace
	;
	; simply show that it works
	view "trace":1:"^trace"
	do post
	view "trace":0:"^trace"
	zwrite ^trace
	kill ^trace
	;
	; recurse big and print ^trace
	view "trace":1:"^trace"
	do recursebig
	do post
	view "trace":0:"^trace"
	zwrite ^trace
	;
	quit
	;
recursesmall ; recurse up to 1300; should be no overflow
        set x=x+1
        if x<1300 do recursesmall
	else  quit
        quit
	;
recursebig ; recurse up to 50000; should overflow
        set x=x+1
        if x<50000 do recursebig
	else  quit
        quit
	;
err ; catch an error, and notify in the log
        set $ztrap=""
        write "ERROR"
        quit
	;
post ; dummy function
	set x=0
	quit
	;
