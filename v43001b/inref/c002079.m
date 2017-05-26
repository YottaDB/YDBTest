c002079	;
	; In Unix, we do not want to kill ourselves if we are in midst of crit since there is no secshr_db_clnup()
	; To avoid test issues and failures in dbg version due to this, we are killing ourselves in Unix through a "zsys"
	; In VMS, we want to test secshr_db_clnup() logic in addition and hence we kill ourselves arbitrary point in time.
	; Hence the separation of Unix and VMS stuff below.
	;
	set unix=$ZVersion'["VMS"
	if unix do unix	; this should not return
	;
	kill ^start	; ^start is the synchronization between child and parent, hence clean it up before jobbing off
	set jmaxwait=0	; In VMS, ask ^job() to return right away after jobbing off the child.
	do ^job("vms^c002079",1,"""""")
	if $d(^start)=0  do
	.	; child has not yet created c002079.crash file. wait until that happens
	.	for  quit:$d(^start)'=0  hang 1
	.	hang 10	; wait for 10 more seconds (since original 5 second wait is not enough) so some updates occur
	quit

unix	;
	for i=1:1:1000  set ^x(i)=$j(i,200)
	set str="zsy ""kill -9 "_$j_""""
	write str,!
	xecute str
	quit	; should not reach here since we would have killed ourselves in the previous statement

vms	;
	; write the command to kill self into a file so driver script c002079.com can kill us
	;
	set file="c002079.crash"
	open file:newver
	use file
	set str1="$ stop /id="_$$FUNC^%DH($j)
	write str1,!
	set str2="$ @gtm$test_common:wait_for_proc_to_die.com """_$$FUNC^%DH($j)_""" -1"
	write str2,!
	close file
	use $p
	;
	; do database updates until driver script c002079.com kills us
	;
	set ^start=1	; signal parent about completion of writing c002079.crash script
	;
	; keep repeating a limited number of updates as otherwise we would have done lots of extensions 
	; of the database before we get killed and we might end up with DBFGTBC integrity errors on crash
	;
	for  kill ^x for i=1:1:1000  set ^x(i)=$j(i,190+$r(10))
	quit
