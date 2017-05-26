c002387	;
	; C9D08-002387 VERMISMATCH error should be reported ahead of FILEIDGBLSEC,DBIDMISMATCH error
	;
	quit
oldverstart;
	set jmaxwait=0
	set ^stop=-1		; set to 0 by the jobbed off child
	set jnomupipstop=1	; signal that this is a kill -9 or STOP/ID 
	set ^parentid=$j
	do ^job("updateandwait^c002387",1,"""""")
	set killchild=$random(2)
	write "Random choice to kill child process is : ",killchild,!
	set filename="killchild.choice"
	open filename
	use filename
	write killchild,!
	close filename
	hang 2            ; sleep for some time and
	set x=$get(^stop) ; do database access and therefore ensure the child has finished touching the database
	quit
updateandwait;
	set ^stop=0
	for i=1:1  quit:^stop=1  hang 1
	quit
oldverstop;
	set ^stop=1
	do wait^job
	quit
newver	;
	set ^stop=1		; should issue VERMISMATCH
	kill ^stop
	quit
