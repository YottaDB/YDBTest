	; This is a simplified alternate test to the trigzsyxplode test
	; The purpose of this test is to hit TPNOTACID inside an implicit
	; transaction.
zsyconflict
	set start=$horolog
	do ^echoline
	do item^dollarztrigger("tfile^zsyconflict","zsyconflict.trg.trigout")
	set x=$increment(^a)
	zsystem "$gtm_tst/com/getoper.csh """_$zdate(start,"MON DD 24:60:SS")_""" """" tpnotacidt.outx """" """_$job_".*TPNOTACID"""
	do ^echoline
	quit

trigrtn
	write "Iteration # : ",$get(^c,0),!
	set $ztvalue=$increment(x)
	set ^b=1
	if $trestart<4 zsystem "$gtm_exe/mumps -run conflict^zsyconflict"
	quit

conflict
	if $ztrnlnm("SEC_SIDE")=$ztrnlnm("PWD") quit
	set x=$incr(^b)
	set x=$incr(^c)
	quit

tfile
	;+^a -command=S -xecute="do trigrtn^zsyconflict"
