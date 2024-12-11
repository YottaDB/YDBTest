;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; WBTEST_RTNOBJ_INTEG will be triggered when numvers >= 2. So purpose of this routine is for make numvers=2
; and that will print out RLNKRECNFL and RLNKINTEGINFO in syslog
;
; numvers is the counter for number of version for routine in relinkctl file when enabled autorelink
;
; First, we set $zroutines to "obj*(src1)" and compile rtn.m in src1 to obj/rtn.o in Process A.;
; This will increase numvers to 1. After that, we start Process B and let process B set $zroutines to "obj*".;
; Then, we proceed to compile different rtn.m in src2 to obj/rtn.o.;
; Now numvers will increase to 2 and this will trigger the WBTEST_RTNOBJ_INTEG and
; will print out RLNKRECNFL and RLNKINTEGINFO in syslog.;
;
procA
	set procBStarted=0
	lock +^procBTerminate
	;
	set oldroutines=$zroutines
	set $zroutines="obj*(src1)"
	zsystem "$gtm_dist/mupip rctldump obj >&! rctldump-a1.log"
	do rtn^rtn
	zsystem "$gtm_dist/mupip rctldump obj >&! rctldump-a2.log"
	;
	set jobCmd="procB^gtmf135435:(output=""procB.mjo"":error=""procB.mje"")"
	job @jobCmd
	for i=1:1:120 lock +^procB:0 set:('$test) procBStarted=1 quit:procBStarted  lock:('procBStarted) -^procB hang 1
	if ('procBStarted) write "TEST-E-FAIL, Failed to start and execute process B in 120 seconds.",! zhalt 1
	;
	zsystem "$gtm_dist/mupip rctldump obj >&! rctldump-b1.log"
	;
	lock -^procBTerminate
	set $zroutines=oldroutines
	do ^waitforproctodie($zjob)	; wait for jobbed/child process to terminate before returning to caller
	quit
	;
procB
	set $zroutines="obj*"
	zcompile "-object=obj/rtn.o src2/rtn.m"
	zlink "obj/rtn.o"
	lock +^procB:60
	if ('$test) write "TEST-E-FAIL, Failed to obtain lock ^procB in 60 seconds." zhalt 1
	lock +^procBTerminate:120
	if ('$test) write "TEST-E-FAIL, Failed to obtain lock ^procBTerminate in 120 seconds." zhalt 1
	quit
	;
