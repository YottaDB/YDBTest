cascade
	write "Nothing here"
	quit

waitfororlbk
	set waittime=600,neederr=1
	do FUNC^waitforfilecreate("ONLINE_ROLLBACK.complete",waittime,neederr)
	quit
