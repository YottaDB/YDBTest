tpupd	; TP updates
	; for use in the C9D12002472 test
	; to test that TP will continue even if a region that is not updated is frozen
	set numjobs=1
	set jmaxwait=300   ; non-zero implies max absolute time to wait for children to die.
	set jdetached=1    ; If defined, then it creates "detached" jobs.
	do ^job("job^tpupd",numjobs,"""""")      ; start 1 background process that does child^share
	zwrite ^a,^b,^c,^z
	quit
job	; TP updates on regions BREG, and DEFAULT (read from AREG, but do not update)
	set jfile="tpupd.out"
	open jfile
	use jfile
	write "PID: ",$J,!
	tstart ()
	s ^b=1
	s ^z=2
	s ^c=^a
	tcommit
	write "OK"
	close jfile
	quit

