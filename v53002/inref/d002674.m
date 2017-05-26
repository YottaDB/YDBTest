XStr ;
; This might not fail in all the platforms.
; It depends on storage layouts and junk laying around in uninitialized memory to manifest.
; Refer TR D9I03-002674 Name indirection may fail with NOUNDEF
test(aipids)
	n lockList
	view "NOUNDEF"
	s lockList="^XStr"
	s %=$$funct("","",lockList)
	d sub(.aipids,lockList)
	q
;---------
sub(pids,lockList)
	n lock,que,qnm,aip
	;s lock=""
	f  s lock=$o(@lockList@(lock)) q
	q
;---------
funct(pid,lockString,lockList)
	n cmd,locks,err,i,lock,lockCount
	s locks(0)=1
	s @lockList@(1)=1
	q 0
	q  ;;#eor#

