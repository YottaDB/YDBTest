; test to verify that the long-standing memory leak problem 
; is fixed; so, go through unw_prof_frame() as many times as
; possible
memleak
	set threshold=0.1
	set storage1=$$tester(1)
	set storage2=$$tester(1)
	set initstorage=(storage1+storage2)/2
	set finstorage=$$tester(10000)
	set ratio=(finstorage-initstorage)/initstorage
	if ratio>threshold write "FAILED: ratio "_ratio_" is greater than the threshold of "_threshold,!
	else  write "PASSED: ratio is within permissible threshold",!
	quit

tester(n)
	kill ^trace
	view "TRACE":1:"^memleak"
	for i=1:1:n do
	.	do ^unwmemleak
	set storage=$zrealstor
	view "TRACE":0:"^memleak"
	quit storage
