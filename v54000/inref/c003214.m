c003214	;
	;
	; Test that validating clue in final retry causes TPFAIL GGGG errors in V53004
	; This test expects global buffers to be a very small value (to induce G restart code)
	;
	set hyphenstr="--------------------------------------------------------"
	set ^max=1000
	do init^c003214
	;
	write hyphenstr,!,"Single-threaded test (should produce NO final-retry restarts and/or TPFAIL errors)",!,hyphenstr,!
	set jobindex=1
	set ^njobs=1
	do test^c003214
	;
	write !,hyphenstr,!,"Multi-threaded test (should produce NO final-retry restarts and/or TPFAIL errors)",!,hyphenstr,!
	set ^njobs=2+$r(7)	; 2 <= ^njobs <= 8
	do ^job("test^c003214",^njobs,"""""")
	quit
	;
init	;
	for i=1:1:^max  s (^a(i),^b(i),^c(i))=$j(i,200)
	quit
	;
test	;
	view "NOISOLATION":"+^a,^b,^c"
	set max=^max
	set njobs=^njobs
	for i=jobindex:njobs:max  do
	.	tstart ():serial
	.	; Ideally one would expect NO restarts because of the code fix but there is long-standing known issue where
	.	; restarts are possible because of stepping on our own buffers. This is avoided in the final retry using a 
	.	; hashtable. Until that issue is resolved, we could see sporadic trestart=1 or 2 or 3 values below hence
	.	; not including it since this output will be part of the reference file
	.	;
	.	; write "i = ",i," $trestart=",$trestart,!
	.	set ^d(i)=^a(i)
	.	for j=1:1:max set x=$get(^b(j)),x=$get(^c(j))
	.	set ^e(i)=^a(i)
	.	for j=1:1:max set x=$get(^b(j))
	.	tcommit
	quit
