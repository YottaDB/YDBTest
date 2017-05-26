prntlogs ;
	; print logs related to socdev test
	zsystem "ls -l *.err"
	set f="serverb.out"
	do ^shrnkfil(f)
	set f="clientb.out"
	do ^shrnkfil(f)
	quit
