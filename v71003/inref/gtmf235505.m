;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
jnlpool		;
	write $ZGBLDIR_": "_$$^%PEEKBYNAME("repl_inst_hdr.jnlpool_semid")_","_$$^%PEEKBYNAME("repl_inst_hdr.jnlpool_shmid"),!
	quit

instname	;
	do setgbldir
	set a=^a(1)
	write $ZGBLDIR_": "_$$^%PEEKBYNAME("repl_inst_hdr.inst_info.this_instname"),!
	quit

setgbldir	;
	set in=$piece($zcmdline," ",1)
	set:""'=in $ZGBLDIR=$select("none"=in:"",1:in)
	quit
