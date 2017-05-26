gtm7443	;
	; Test that idle EPOCHs are not written unnecessarily
	;
	; In this scenario two processes interleave their updates such that each process' idle epoch timer would find 
	; no dirty buffers at the start of end of the idle timer. Without the fix to gtm-7443, each process would
	; write an idle EPOCH even though the other process had done an update in between. With the fix no idle epochs
	; would be written.
	;
	set jnodisp=1
	do ^job("child^gtm7443",2,"""""")
	quit
child	;
	if jobindex=1  do child1
	if jobindex=2  do child2
	quit
child1	;
	set ^x(1)=1
	hang 2
	for i=1:1  quit:$data(^y(1))=1  hang 0.1
	hang 2
	for i=2:1:5 set ^x(i)=$j(i,200) hang 7
	do nonidle
	quit
child2	;
	for i=1:1  quit:$data(^x(1))=1  hang 0.1
	hang 2
	for i=1:1:5 set ^y(i)=$j(i,200) hang 7
	do nonidle
	quit
nonidle	;
	; do one update at end before halting as otherwise this could cause an idle epoch to be written
	; because of the "hang 7" in the previous for loop. And that would interfere with the test.
	set ^nonidle(jobindex)=jobindex
	quit
