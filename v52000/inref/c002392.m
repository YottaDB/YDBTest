c002392	;
	; C9D08-002392 Online backup has integrity errors in case wcs_recover() runs concurrently
	;
	; Do a mix of TP and NON-TP updates with multiple GT.M processes on multiple regions.
	;
	quit
start	;
	set jmaxwait=0
	set ^stop=0
	set ^waitforbackup=0
	do ^job("child^c002392",5,"""""")
	quit
	;
child	;
	set unix=$zversion'["VMS"
	if 'unix  view "GDSCERT":1	; we have seen rare integ errors in VMS hence turning block-certification ON
	set str="abcdef"
	if jobindex'=2  do  quit
	.	for i=1:1 quit:^stop=1  do
	.	.	set rand=$random(2)
	.	.	if rand=1 tstart ():serial
	.	.	set randcnt=1+$random(30)
	.	.	for j=i:1:i+randcnt  do
	.	.	.	for k=1:1:$l(str)  do
	.	.	.	.	set xstr="set ^"_$extract(str,k)_"("_j_","_jobindex_")=$j("_j_","_(20+$random(100))_")"
	.	.	.	.	write $h," : ",xstr,!
	.	.	.	.	xecute xstr
	.	.	if rand=1 tcommit
	.	.	if 'unix hang $random(10)*0.01	; slow down update rate in VMS to avoid EXBYTLM quota failures
	.	.	set i=j
	for  quit:^stop=1  do
	.	; Check if parent script has signalled us to wait for its MUPIP BACKUP to finish before doing further
	.	; kills (possible if the MUPIP BACKUP encounters a BACKUPKILLIP message).
	.	; This code is currently unnecessary because both Unix and VMS parent scripts have been reworked NOT to
	.	; handle BACKUPKILLIP messages. If ever it starts happening, those scripts need to handle it then which is
	.	; why the logic that is here (which is already ready for the BACKUPKILLIP change) is not removed.
	.	for  quit:^waitforbackup=0  hang 1
	.	hang $random(10)*0.1
	.	set rand=$random(6)+1
	.	set xstr="kill ^"_$extract(str,rand)
	.	write $h," : ",xstr,!
	.	xecute xstr
	quit
stop	;
	set ^stop=1
	do wait^job
	quit
sleepshort	;
	; short sleeps should be used in case test is running with PRO image. This is because we cannot do white-box testing
	; there (only dbg allows white-box testing currently) which means we cannot trigger wcs_recover which means the
	; intent of this test cannot be satisfied in this case. Therefore we do minimal functionality testing in this case
	; and so better to have minimal sleeps in between backups.
	;
	hang $random(3)*0.1
	quit
sleeplong	;
	; LONG sleeps should be used in case test is running with DBG image. It is ok to do this because we can do white-box
	; testing and we are bound to trigger wcs_recover frequently. That will reduce the GT.M update throughput rate.
	; So it is ok to sleep a while.
	;
	hang $random(20)*0.1
	quit
