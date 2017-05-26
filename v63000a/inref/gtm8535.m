;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8535	;
	;
	; When we come here, the semaphore counter is 8K for both db and instance file
	; We start 3 processes that open only the jnlpool and 3 more processes that open only the database file
	; Since this test sets gtm_db_counter_sem_incr to 8K, the counters for both db and instance file will reach 32K
	; And since we do not enable qdbrundown on both db and instance file, we expect error messages for both.
	;
	quit
db	;
	write "Test DB counter overflow error message",!
	Job dbchild1^gtm8535:(output="dbchild1.mjo":error="dbchild1.mje")
	do ^waitforproctodie($zjob,300)
	quit
dbchild1;
	set x=$get(^dummy) ; opens the db and counter gets to 8K
	Job dbchild2^gtm8535:(output="dbchild2.mjo":error="dbchild2.mje")
	do ^waitforproctodie($zjob,300)
	quit
dbchild2;
	set x=$get(^dummy) ; opens the db and counter gets to 16K
	Job dbchild3^gtm8535:(output="dbchild3.mjo":error="dbchild3.mje")
	do ^waitforproctodie($zjob,300)
	quit
dbchild3;
	set x=$get(^dummy) ; opens the db and counter gets to 24K
	Job dbchild4^gtm8535:(output="dbchild4.mjo":error="dbchild4.mje")
	do ^waitforproctodie($zjob,300)
	quit
dbchild4;
	set x=$get(^dummy) ; opens the db and counter gets to 32K (expect error)
	quit
repl	;
	write "Test Replication instance file counter overflow error message",!
	Job replchild1^gtm8535:(output="replchild1.mjo":error="replchild1.mje")
	do ^waitforproctodie($zjob,300)
	quit
replchild1;
	set x=$get(^dummy) ; opens the jnlpool first and counter gets to 8K
	Job replchild2^gtm8535:(output="replchild2.mjo":error="replchild2.mje")
	do ^waitforproctodie($zjob,300)
	quit
replchild2;
	set x=$get(^dummy) ; opens the jnlpool first and counter gets to 16K
	Job replchild3^gtm8535:(output="replchild3.mjo":error="replchild3.mje")
	do ^waitforproctodie($zjob,300)
	quit
replchild3;
	set x=$get(^dummy) ; opens the jnlpool first and counter gets to 24K
	Job replchild4^gtm8535:(output="replchild4.mjo":error="replchild4.mje")
	do ^waitforproctodie($zjob,300)
	quit
replchild4;
	set x=$get(^dummy) ; opens the jnlpool first and counter gets to 32K (expect error)
	quit
