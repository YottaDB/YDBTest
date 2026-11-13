;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; USE of a SOCKET device with an empty LISTEN address (see r208/u_inref/socket_use_listen_empty-ydb1392.csh)
ydb1392	; USE of a SOCKET device with an empty LISTEN address issues INVPORTSPEC
	quit
stage1	; USE with LISTEN="" of a socket device that listens on a LOCAL socket
	new s
	set s="sock1"
	open s:(listen="ydb1392a.s:LOCAL"):5:"socket"
	use $principal
	do check("use s:(listen="""")","INVPORTSPEC")
	close s
	quit
stage2	; Controls: USE with CONNECT="", with a LISTEN address that is too long and with a valid LISTEN address, and
	; OPEN with LISTEN=""
	new s
	set s="sock2"
	open s:(listen="ydb1392b.s:LOCAL"):5:"socket"
	use $principal
	do check("use s:(connect="""")","INVPORTSPEC")
	do check("use s:(listen=$translate($justify("""",128),"" "",""x""))","ADDRTOOLONG")
	do check("use s:(listen=""ydb1392c.s:LOCAL"")","")
	close s
	do check("open ""sock3"":(listen=""""):5:""socket""","INVPORTSPEC")
	quit
check(cmd,experr)	; XECUTE cmd, and check that it issues experr (or no error if experr is "")
	new err
	do try(cmd)
	use $principal
	if experr=err write "PASS : ",cmd," : ",$select(""=err:"no error",1:err),!
	else  write "FAIL : ",cmd," : got [",err,"] but expected [",experr,"]",!
	quit
try(cmd)	; XECUTE cmd, and set err to the mnemonic of the error it issues (if any)
	new $etrap
	set err="",$etrap="use $principal set err=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""" quit"
	xecute cmd
	quit
