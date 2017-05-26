gtm7020b
	tstart ()
	set ^a=101
	if $trestart<2 set x=$ztrigger("i","+^%priv1 -commands=SET -xecute=""set x=1""")
	if $trestart=2 zsystem "$gtm_exe/mumps -run conflict^gtm7020b"
	if $trestart<3 trestart 
	tcommit

conflict
	set x=$ztrigger("i","+^%priv2 -commands=SET -xecute=""set x=2""")
	quit
