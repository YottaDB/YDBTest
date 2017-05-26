rwtest
	;tstart
        set $ZTRAP=" GOTO error"    
	write "Locking globle var ^a",!
	lock ^a:1     ;M sets $TEST to 1 if lock get the resource before timeout(1 sec) 
	if $t  write "Lock passed     $TEST=",$TEST,!
	else  write "Lock failed"
	write "^a=",^a,! 
	if ^a'=6  write "set ^a=6",!  s ^a=6
	else  write "set ^a=10",!  s ^a=10  
	w " ^a=",^a,!
	write "unlock var ^a",!       
	lock -^a             ; unlock ^a
  	w "--------- Successful updating ----------",!
	;write "kill ^a",!
	;kill ^a  
	;tcommit
	quit

error	;w $ZM(150373594),!
	write !,$zstatus,!
	w !,"------ Updating a read-only database FAILED as expected ------ ",!
	;tcommit
	quit