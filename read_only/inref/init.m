init:
	set $ZTRAP=" GOTO error"
	write "set ^a=1,^b=2,^c=3",!
	lock (^a,^b,^c):5
	if $t set ^a=1,^b=2,^c=3
	else  write "Lock failed"
	lock
	quit
error	write !,$zstatus,!
	write !,"------ Updating failed ------ ",!
	quit
