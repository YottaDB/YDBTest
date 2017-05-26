c002736	;
	; Testcase for two scenarios (fixed as part of C9F06-002736 and C9F03-002709 respectively).
	; a) A REPLOFFJNLON error during transaction commit
	;	^a maps to AREG which is journaled but NOT replicated.
	;	^x maps to DEFAULT which is journaled and replicated.
	;	Individual updates to these regions will not error but a TP transaction updating both regions will error out.
	; b) Ensure that gv_target and gv_cur_region are maintained in sync before transferring control to $ZTRAP.
	;    Not doing so will cause the reference to ^x(100) to be searched in AREG (instead of DEFAULT) which
	;    will in turn manifest as GVUNDEF errors (in pro) or assert failures in op_gvname.c (in dbg).
	;    Note that since there are two regions in this test and since the region that ends up being the current region
	;    while executing $ztrap is dependent on the ftok ordering of the database files, there is approximately a 50% chance
	;    that this test will pass even in versions that do not contain the fix to keep gv_cur_region/gv_target in sync.
	;
	set $ztrap="do ztr"
	tstart ():serial
	set ^|"tworeg.gld"|a=1
	tcommit
	;
	tstart ():serial
	set ^x=1
	tcommit
	;
	set ^|"tworeg.gld"|a=1
	;
	for i=1:1:100 s ^x(i)=$j(i,200)
	set ^x=1
	;
	tstart ():serial
	set ^x=0.5
	set ^|"tworeg.gld"|a=1
	set ^x=1
	tcommit
	;
	quit
ztr	;
	set $ztr="break"
	write $zstatus,!
	set result=^x(100)
	if $tlevel  trollback
	halt
