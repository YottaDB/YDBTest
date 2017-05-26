gtm7402	;
	; Job off child processes some of which will encounter GBLOFLOW error while inside a KILL.
	; After the GBLOFLOW error, do an update in the error trap in EREG (a different region) which is 
	; guaranteed not to encounter the GBLOFLOW error again. And then halt.
	; Previously, we used to see the kill_in_prog and abandoned_kills counter incorrectly set in two regions.
	; After the code fix, we will see the two counters zero in all regions.
	;
	do ^job("child^gtm7402",5,"""""")
	quit
child	;
	; do ^sstep
	set $etrap="do etrap halt"
	for i=1:1  do
	.	write "i = ",i,!
	.	set (^a(i),^adummy(i))=$j(1,200)
	.	set (^b(i),^bdummy(i))=$j(1,200)
	.	set (^c(i),^cdummy(i))=$j(1,200)
	.	set (^d(i),^ddummy(i))=$j(1,200)
	.	set (^f(i),^fdummy(i))=$j(1,200)
	.	set (^g(i),^gdummy(i))=$j(1,200)
	.	set (^h(i),^hdummy(i))=$j(1,200)
	.	kill ^a,^b,^c,^d,^f,^g,^h
	quit
etrap	;
	write "$zstatus = ",$zstatus,!
	zshow "*":^e($j)
	quit
