; This test tries to generate failures due to a DO command with a null
; argument.  A DO with no argument was once considered invalid, but it
; is now a valid statement in MUMPS and this test "fails" because the
; argumentless do is no longer flagged as an error.  Since this test is
; no longer appropriate, it has been removed from the instream.txt/csh
; files and is no longer executed.
; Peter Psyhos - 5/13/92
per0320	;per0320 - Reject D  and D @""
	;
	s c=0
	s zl=$zl,zt=$zt,$zt="s next=$zpos,$p(next,""+"",2)=$p(next,""+"",2)+1 w !,$zs zg @(zl_"":""_next)"
	s x=""
	x "d  s c=c+1 w !,""Do null failed"""
	;
	d @"" s c=c+1 w !,"Do indirect null failed"
	;
	d @x s c=c+1 w !,"Do indirect null variable failed"
	;
	x "d @x s c=c+1 w !,""xecute Do indirect null variable failed"""
	;
	s $zt=zt
	w !,$s(c:"BAD result",1:"OK")," from test of Do null arguments"
	q
