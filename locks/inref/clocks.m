; 1999-April-02 -- segalle -- The functional change that enabled this test to 
; demonstrate "sleeplock" (in GT.M versions through at least V40001E) was adding 
; "hang 1" while holding the lock. 

; See "NOTE:" below for how to perform an alternate test (out-of-order locking
; by the application). That change requires fewer processes to demonstrate sleeplock.

; Code adapted from earlier versions of lock contention tests
; written by Cha He, Layek, and myself. 


clocks	; to test when there are multiple processes trying to lock the same
	; resources at the same time.
	;
	W "Main task started",!
	S cnt=3
	L +^TEST
	F I=1:1:cnt D
	. set jobno1=2*I-1
	. set jobno2=2*I
	. job @("multi1(jobno1):(output=""clocks.mjo"_jobno1_""":error=""clocks.mje"_jobno1_""")")
	. ; NOTE: exchange the following two lines to demonstrate out-of-order locking
	. ; by the application.
	. job @("multi1(jobno2):(output=""clocks.mjo"_jobno2_""":error=""clocks.mje"_jobno2_""")")
	. ; job @("multi2(jobno2):(output=""clocks.mjo"_jobno2_""":error=""clocks.mje"_jobno2_""")")
	L -^TEST
	H 60
	L +^TEST
	ZWR ^result
	W "Main task ended",!
	Q

multi1(jobno)	; multilocks in forward order
	new lockfn
	set lockfn="$$m1()"
	do multi(jobno)
	quit 

multi2(jobno)	; multilocks in backward order
	new lockfn
	set lockfn="$$m2()"
	do multi(jobno)
	quit 

m1()	lock +(^a,^b,^c,^d,^e,^f,^g)
	write "lock in forward order",!
	quit $t

m2()	lock +(^a,^b,^c,^d,^e,^f,^g)
	write "lock in backward order",!
	quit $t

	; this routine is not currently used 
job1(jobno,jobcnt)
	W $ZDate($Horolog,"24:60:SS")," Job ",jobno," started",!
	S $ZT="g ERROR"
	L +^TEST(jobno)
	S index=10
	For j=1:1:5 D
	. L +(^a(index),^b(index))
	. W "Job no ",jobno," Got incr lock at ",j,! 
	. H 1
	. L -(^a(index),^b(index))
	W $ZDate($Horolog,"24:60:SS")," Job ",jobno," ended",!
	Q

multi(jobno)	
	set started=$ZDate($Horolog,"24:60:SS")
	write $ZDate($Horolog,"24:60:SS")," Job ",jobno," started",!
	set $ZT="g ERROR"
	lock +^TEST(jobno)
	; this should guaranteen all the jobs start simultanously
	for j=1:1:1000 do
	. if @lockfn do
	. . write "Job No ",jobno," got incr lock at ",j,!
	. . set ^joblog(jobno,started,$job,j)=$ZDate($Horolog,"24:60:SS"),^result(jobno)="GOT THE LOCK"
	. . lock -(^a,^b,^c,^d,^e,^f,^g)
	. else  w "didn't get lock",!
	write $ZDate($Horolog,"24:60:SS")," Job ",jobno," ended",!
	set ^joblog(jobno,started,$job,"done")=$ZDate($Horolog,"24:60:SS")
	quit

ERROR	S $ZT="h"
	ZSHOW "*"
	ZM +$ZS




