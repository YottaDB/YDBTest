d002386	;
	for i=1:1:10000 s ^a(i)="a"_i
	quit
getmax(ra,rb,rc,shm)	; get the max resync seqno for test D9D10002386
	; input: ra,rb,rc: resync seqno of the regions in hex format.
	; shm  : if the hex numbers are from shm, get rid of the 0x prefix first
	if shm do
	. set ra=$extract(ra,3,18)
	. set rb=$extract(rb,3,18)
	. set rc=$extract(rc,3,18)
	set da=$$FUNC^%HD(ra)
	set db=$$FUNC^%HD(rb)
	set dc=$$FUNC^%HD(rc)
	set max=da
	if (db>max) set max=db
	if (dc>max) set max=dc
	;
	set fn="max_resync.txt"
	open fn:newversion
	use fn
	write max
	close fn
	quit 
