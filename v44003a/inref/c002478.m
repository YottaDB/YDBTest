	; C9D12-002478 marvin dbg cores with v44003 (find_line_addr has SEGV)
ind	; to verify the validity of indirect code generated after MAXARGCNT error.
	S $ZT="S zt="""" d lab($ZS) zgoto "_$zl_"-1"
	s x="S a(131)=a(1)"
	f i=2:1:128 s x=x_"_"",""_a"_"("_i_")"
	w x,!
	x x
	q

rtn	; to verify the validity of routine code generated after MAXARGCNT error.
	; initialize the string that will cause MAXARGCNT error
	s x="S a(131)=a(1)"
	f i=2:1:128 s x=x_"_"",""_a"_"("_i_")"

	; generate a routine off-the-fly (rtnerr.m) running which generates MAXARGCNT
	s rtnerr="rtnerr.m",rtnval="rtnval.m"
	o rtnerr:newversion
	u rtnerr w " ",x,!," q"
	c rtnerr

	; generate a valid routine off-the-fly (rtnval.m) to be after the error
	o rtnval:newversion
	u rtnval w " w ""rtnval called"",!",!," q",!
	c rtnval

	zcom rtnerr,rtnval
	d ^rtnval
	u $p
	q

lab(m)	
	w m,! q
