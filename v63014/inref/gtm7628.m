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
; These are helper functions for testing v63014/gtm7628. We try to allocate 64GiB journal and receive pools.
;
; initDB: Helper routine to just add a few records to the database.
initDB
	for i=1:1:10000 set ^a(i)=$justify(i,64)
	quit

; printJPSize: Helper routine to print out the size of the journal pool
printJPSize
	set jnlpoolSize=$$^%PEEKBYNAME("jnlpool_ctl_struct.jnlpool_size",,"U")
	write !,"Journal pool size: ",$justify(jnlpoolSize/(1024**3),10,4)," GB (",jnlpoolSize,"/0x",$$FUNC^%DH(jnlpoolSize,16),")",!
	quit

; printRPSize: Helper routine to print out the size of the receive pool
printRPSize
	set recvpoolSize=$$^%PEEKBYNAME("recvpool_ctl_struct.recvpool_size",,"U")
	write !,"Receive pool size: ",$justify(recvpoolSize/(1024**3),10,4)," GB (",recvpoolSize,"/0x",$$FUNC^%DH(recvpoolSize,16),")",!
	quit
