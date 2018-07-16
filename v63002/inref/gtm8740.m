;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
gtm8740
	write "$$^%PEEKBYNAME('jnlpool_ctl_struct.instfreeze_environ_inited')=",$$^%PEEKBYNAME("jnlpool_ctl_struct.instfreeze_environ_inited"),!
	quit

waitfn
	set x="pid.out"
	open x
	use x
	write $job
	close x
	set ^stop=0
	for  quit:^stop
	quit
