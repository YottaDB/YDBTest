zchmod	;;; Test of chmod inside of M process
	zsystem "chmod 444 mumps.dat"
	zsystem "ls -l mumps.dat" 
	quit
mjl	zsystem "chmod 444 mumps.mjl"
	zsystem "ls -l mumps.mjl"
	quit
bckdat	zsystem "chmod 666 mumps.dat"
	zsystem "ls -l mumps.dat" 
	quit
bckjnl	zsystem "chmod 666 mumps.mjl"
	zsystem "ls -l mumps.dat" 
	quit