per0481	;PER0481 - accvio when indirection of mval whose mstr addr == 0
	s c=0
	s zt=$zt,$zt="s next=$zpos,$p(next,""+"",2)=$p(next,""+"",2)+1 w !,$zs g @next"
	s a1=$p("",",",2)
	s b=@a1 s c=c+1 w !,"Set did not detect UNDEF"
; The following two lines of code try to generate an error by using a DO
; with no argument, by means of indirection.  A DO with no argument used
; to be illegal, but it is now valid, therefore the test is no longer
; appropriate and has been commented out.
;	s a2=$p("",",",2)
;	d @a2 s c=c+1 w !,"Do did not detect UNDEF"
	s a3=$p("",",",2)
	s @a3=0 s c=c+1 w !,"Set indirect did not detect UNDEF"
	s $zt=zt
	w !,$s(c:"BAD result",1:"OK")," from indirection on an internally generated NUL string"
	q
