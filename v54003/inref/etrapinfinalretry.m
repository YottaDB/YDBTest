; Test that an Error Trap which does DB actions (GET / SET) can cause one or more
; restarts even when in a final retry. These restarts should be treated as if
; they happened in the penultimate retry (normal operation of code). We should
; not see any asserts or other issues.
etrapinfinalretry
	kill ^a,^b,^stop
	; redirect all output to a file and use taildata with ^tail
	set stdout="routine.outx",taildata=""
	; dse related variables
	set dumpfilehdr="dump -nocrit -fileheader",dseprompt="DSE> "
	; debugging and stopping
	set ^stop=0,quit=0,debug=$select($data(^debug):^debug,1:0)
	; tell ^job not to check for errors or wait for the child
	set jnoerrchk=1,jmaxwait=0
	; randomly choose to zgoto or quit out of the ETRAP
	set switch=$select($data(^switch):^switch,1:$random(2))
	if switch=1 set $etrap="goto traphandler^etrapinfinalretry"
	else  set $etrap="do traphandler^etrapinfinalretry"
	; start the test
	do ^echoline
	set start=$HOROLOG
	do longrunning
	do ^tail(-1,stdout,.taildata)
	set tailed=$order(taildata(""))
	write taildata(tailed),!
	set stop=$HOROLOG
	; save the test time, used to check if the test took too long
	set ^time=$$^difftime(stop,start)
	do ^echoline
	quit

longrunning
	open stdout:newversion
	use stdout
	write "My PID is ",$job,!
	write "My $ETRAP is ",$ETRAP,!
	; startup conflict job
	do ^job("conflict^etrapinfinalretry",1,"""""")
	set conflictpid=$zjob
	; setup DSE process prior to starting transactions to avoid a deadlock
	set pipe="dsepipe" ; check who has CRIT
	open pipe:(command="$gtm_exe/dse")::"pipe"
	use pipe
	for i=1:1 quit:$zeof  read line:1 quit:line=dseprompt  ; strip off the DSE startup headers
	; start main transaction
	tstart ()
	use stdout ; in case we restart while using DSE
	if $trestart>4 use $p write "excessive retries, halting",! trollback  set ^stop=1 halt
	if debug write "Restart #",$trestart,!
	; after 10 restarts, kick off the pacifist job to stop the conflict job
	if ($increment(restarts)=10) do ^job("pacifist^etrapinfinalretry",1,"""""")
	; once we hit $TRESTART 3 we are in the final retry
	if $trestart>2 do
	.	set quit=1	   ; set quit=1 to stop the loop on line 71
	.	; find out who has CRIT
	.	use pipe
	.	write dumpfilehdr,!
	.	for i=1:1:150 quit:$zeof  read line:1 quit:line=dseprompt  do
	.	.	set lineio(i)=line ; for debugging
	.	.	if line["In critical section" set crit=$$FUNC^%HD($piece($piece(line,"0x",2)," ",1))
	.	; if crit is undef, that means something might be wrong with the DSE output
	.	if '$data(crit) do
	.	.	use $p
	.	.	write "crit is undef",!
	.	.	zwrite
	.	.	use stdout
	.	.	set crit=0
	.	use stdout
	.	if debug write "The PID ",crit," has CRIT ",!
	.	set $ecode=",42," ; bogus ECODE to cause an error
	for i=1:1:1000000 quit:quit=1  set ^a=i
done
	; ETRAP handler goes straight to done when not restarted, so tcommit here
	tcommit
	use stdout
	if debug write "All done @ $TLEVEL",$TLEVEL,!
	if debug zwrite ^a,^b
	set ^stop=1
	use pipe write "quit",! close pipe
	use $p
	close stdout
	do wait^job
	quit

	; update ^a,^b forcing the longrunning job to restart
conflict
	zshow "d"
	write "I am the conflict job ",$job,!
	for i=1:1:10000000 quit:^stop=1  do
	.	tstart ()
	.	set ^b=$increment(^a)
	.	tcommit
	.	if (i#100000)=0 hang 1  ; give the long running job some breathing room
	quit

pacifist
	zshow "d"
	set ^stop=1
	quit

	; we goto into the trap handler, therefore we zgoto $zlevel-1
traphandler
	new line
	set $ecode=""
	if debug zshow "s" write $zstatus,!
	; we expect INVECODEVAL, because we set $ecode to a bad value, halt on others
	if $zstatus'["INVECODEVAL"  do
	.	use $p
	.	write "unexpected:",$zstatus,! zshow "*"
	.	if $tlevel>0 trollback
	.	set ^stop=1
	.	halt
	; find out who has CRIT right now
	use pipe
	write dumpfilehdr,!
	for i=1:1:150 quit:$zeof  read line:1 quit:line=dseprompt  do
	.	set elineio(i)=line ; for debuging
	.	if line["In critical section" set etrapcrit=$$FUNC^%HD($piece($piece(line,"0x",2)," ",1))
	use stdout
	write "PID ",$job," is in the ETRAP in final retry||"
	write "PID ",crit," had CRIT before ETRAP||"
	write $select(($job=crit):"CRIT",1:"NOCRIT"),"||"	; This should always be TRUE
	write "PID ",etrapcrit," has it inside the ETRAP||"
	write $select(($job=etrapcrit):"CRIT",1:"NOCRIT"),"||"	; The current code this is always FALSE
	write "ETRAP has fired ",$increment(nonce)," times||"	; The current code this can be 1 or more
	write "TLEVEL=",$TLEVEL,"||"
	write "ZLEVEL=",$ZLEVEL,"||"
	write "TRESTART=",$TRESTART,!
	set j=^b,^b=$increment(j)
	if debug zwrite ^b,j
	set ^b=42
	quit:switch=0
	zgoto ($zlevel-1):done

