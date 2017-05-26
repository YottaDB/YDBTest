	; Test for S9K07-002782 (FOR loop does not iterate)

	;
	; Any counters or iterative stops on the FOR loop will cause it to behave normally so plan to
	; interrupt it in 4 seconds (if it still exists) and see if it did any iterations at all. It
	; will always do at least 1. So if it gets to that point end the test as the loop will be running.
	; 
	Set ourlvl=$ZLevel
	Set loopcntr=0,^done=0
	Set $ZInterrupt="ZGoto:loopcntr>0 "_$ZLevel_":Done"
	Set jmaxwait=0
	Do ^job("intrproc^D9K07002782",1,$Job)

	Do
	. For  Do
	. . If loopcntr>999999999 Set loopcntr=1 zgoto ourlvl:Done	; If waited long enuf for interrupt (fail)
	. . Set loopcntr=loopcntr+1
	. . 

Done
	Set ^done=1
	Do wait^job
	Set pass=(loopcntr>1)
	Write "D9K07002782 ",$Select(pass:"PASS",1:"FAIL"),!
	ZWrite:'pass
	Quit

intrproc(pid)
	Hang 4		; Let parent get going
	For  Quit:^done  Do
	. ZSystem "$gtm_dist/mupip intrpt "_pid_" >>& intrptrslt.log"
	. If $ZSigproc(pid,0)'=0 Set ^done=1	; Note $ZSystem is not set proerly by mupip intrpt
	. Else  Hang .5
	Quit
