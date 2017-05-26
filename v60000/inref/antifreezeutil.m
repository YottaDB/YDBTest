antifreezeRundown	;
	write "This entryref is not allowed",!
	quit

default	;
	set ^x=1			; Touch the DEFAULT region
	view "FLUSH"			; Flush the updates before suicide
	write "PID=",$job,!		; Record the PID for aid in debugging
	zsystem "kill -9 "_$job		; Suicide, but leave shared memory around
	hang 30				; To take into account asynchronous Kills.
	quit

updatehang	;
	set ^a=1			; Touch the AREG region
	write "PID=",$job,!		; Record the PID for aid in debugging
	for  quit:$data(^astop)  do
	. ; Keep the process attached to AREG's shared memory. Rundown shouldn't remove this.
	. hang 1
	quit

suicide	;
	set ^a($incr(^i))=$j
	set ^x($incr(^i))=$j
	zsystem "kill -9 "_$job
	hang 30	; To account for asynchronous Kills
	quit

updates4reorg	;
	for i=1:1:200  do
	. set ^a($incr(^i))=$j(i,200)
	. set ^x($incr(^i))=$j(i,200)
	quit
