;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to verify that $ZINTERRUPT cannot be invoked in a nested fashion. Pre V6.3-014, this test
; fails with an assert failure in a debug build. Example:
;
;    %GTM-F-ASSERT, Assert failed in sr_port/mdb_condition_handler.c line 797 for expression (!dollar_zininterrupt)
;
; Operation: Start the main routine (gtm9328^gtm9328) in one process then repeatedly drive intrpt^gtm9328. Our script
; does this 100 times. If the main routine is still running, then the test has passed successfully.
;
gtm9328
	set $ztrap="do ztr"
	set ^pid=$job
	set ^done=0
	set ^ready=1
	set $zinterrupt="do zinterrupt"
	for i=1:1 quit:^done  hang 0.001
	write "gtm9328 complete",!
	quit
;
; Routine to drive to send interrupts to main routine. It we only send one, it doesn't cause the failure but if we
; send two, it does fail on versions prior to V6.3-014.
intrpt
	for i=1:1 quit:^ready  hang 0.001
	set pid=^pid
	for i=1:1:2 if $zsigproc(pid,10)
	quit

;
; When the main routine gets a zinterrupt, this routine is driven. This routine and the routines it calls do alternate
; error handling (one frame does etrap, the next does $ztrap, then repeat) which is what seems to cause this issue.
;
zinterrupt
	new $etrap,j
	do zintr1
	quit

zintr1
	new $ztrap
	do zintr2
	quit

zintr2
	new $etrap
	IF $ZJOBEXAM()
	quit
;
; If an error occurs while our main $ztrap is in effect, we come here. We do not expect this to fire.
;
ztr
	write "Error trap reached",!
	quit
