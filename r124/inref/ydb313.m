;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
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
		write $$^%PEEKBYNAME("repl_inst_hdr.jnlpool_semid")_","_$$^%PEEKBYNAME("repl_inst_hdr.jnlpool_shmid")
		quit

recvpool	;
		write $$^%PEEKBYNAME("repl_inst_hdr.recvpool_semid")_","_$$^%PEEKBYNAME("repl_inst_hdr.recvpool_shmid")
		quit
