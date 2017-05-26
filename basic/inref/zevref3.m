	; Valid test cases to check functionality of ZYERROR when set with
	; indirect arguement to entry references
     	; format of entryref : label+offset^module.

INDIRECTSUBROUTINE1	w "Testing ZYERROR @Label...",!
	s $zt="do ^ztraph"
	set label="INDIRECTSUBROUTINE2",$zyerror="@label" 
	kill x
	set x=x+1 ;bad line
	;
 	w "Testing ZYERROR @Lable+offset..."
        set label="INDIRECTSUBROUTINE3",off=1,$zyerror="@label+off"
	set x=0
	w 1/x,! ;bad line
	;
    	w "Testing ZYERROR @Label+@module..."
        set label="labelinanothermoduleforzyerror",mod="zeleaf",$zyerror="@label^@mod"
        set x=""
	w @x,! ;bad line
	;
	w "Testing ZYERROR @(Label+offset+module)...",!
        set ind="labelinanothermoduleforzyerror+1^zeleaf",$zyerror="@ind" 
        kill x
	set x=x+1 ;bad line
	;
	w "Testing ZYERROR with no quit cmd in its handler...",!
        set $zyerror="report^zyerrh" 
        kill x
	set x=x+1 ;bad line
	;
	w "end of SUB1",!
        quit

INDIRECTSUBROUTINE2    w "done(SUB2)",!
	do report^zeleaf
	w "end of SUB2",!
        quit

INDIRECTSUBROUTINE3	goto INDIRECTSUBROUTINE3+2	
	w "done(SUB3+1)",!
	do report^zeleaf
	w "end of SUB3",!
 	quit
