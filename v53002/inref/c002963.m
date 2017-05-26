c002963	;
	;
	; Test that SET $ZGBLDIR followed by TSTART does NOT fail with SIG-11 if no other preceding global references
	;
	set $zgbldir="mumps.gld"
	tstart ():serial
	set ^x=1	; do a database update just to check that it works fine (not related to the fundamental issue)
	tcommit
	quit
