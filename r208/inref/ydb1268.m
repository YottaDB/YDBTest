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
; YDB#1268 : a PIPE OPENed with both "writeonly" and stderr="devname" produced a stderr device that
; could not be READ. "iopi_open.c" creates that device and sets read_only on it, then opens it with
; the same deviceparameter list the caller gave the PIPE, so "iorm_use.c" reached its iop_writeonly
; case and set write_only on it as well. "iorm_readfl.c" then refused the READ with DEVICEWRITEONLY.
;
; Each label below is run in its own process by pipe_stderr_writeonly-ydb1268.csh.
;
; Both helpers trap their own errors and GOTO rather than QUIT. A QUIT out of an $ETRAP unwinds the
; calling frame, which would abandon every later assertion in the stage: on a build without the fix
; the first failure would be the only line printed, and the assertions that guard against the fix
; going too far would never run.
;
; An error mnemonic is reported without its "%YDB-E-" prefix so that com/errors.csh does not catch an
; error this subtest deliberately provokes.
;
ydb1268	;
	write "Run one label at a time. See pipe_stderr_writeonly-ydb1268.csh",!
	quit
	;
	; ---------------------------------------------------------------------------------------------
wonly	; writeonly with stderr= : the YDB#1268 case, plus the two directions that must NOT change
	open "p1":(shell="/bin/sh":command="echo to-stderr 1>&2":writeonly:stderr="perr1")::"pipe"
	do chkread("perr1","to-stderr","the stderr device of a writeonly PIPE can be READ")
	do chkerr("W","perr1","DEVICEREADONLY","a WRITE to that stderr device is still refused")
	do chkerr("R","p1","DEVICEWRITEONLY","a READ from the writeonly PIPE device itself is still refused")
	use $principal close "p1"
	quit
	;
	; ---------------------------------------------------------------------------------------------
ronly	; readonly with stderr= : worked before the fix, must keep working
	open "p2":(shell="/bin/sh":command="echo to-stdout; echo to-stderr 1>&2":readonly:stderr="perr2")::"pipe"
	do chkread("perr2","to-stderr","the stderr device of a readonly PIPE can be READ")
	use $principal close "p2"
	quit
	;
	; ---------------------------------------------------------------------------------------------
plain	; stderr= with neither direction : worked before the fix, must keep working, both devices read
	open "p3":(shell="/bin/sh":command="echo to-stdout; echo to-stderr 1>&2":stderr="perr3")::"pipe"
	do chkread("perr3","to-stderr","the stderr device of a plain PIPE can be READ")
	do chkread("p3","to-stdout","the PIPE device itself still gives the command stdout")
	use $principal close "p3"
	quit
	;
	; ---------------------------------------------------------------------------------------------
reuse	; a CLOSE followed by an OPEN reusing BOTH device names in the same process must start clean.
	; The stderr device is created by the PIPE OPEN rather than by the caller, so this is the one path
	; where a direction left over from a previous OPEN could reach it.
	open "p4":(shell="/bin/sh":command="echo to-stderr 1>&2":writeonly:stderr="perr4")::"pipe"
	do chkread("perr4","to-stderr","first OPEN, writeonly, reads its stderr device")
	use $principal close "p4"
	open "p4":(shell="/bin/sh":command="echo to-stdout; echo to-stderr 1>&2":readonly:stderr="perr4")::"pipe"
	do chkread("perr4","to-stderr","second OPEN, readonly, reusing both device names reads it too")
	use $principal close "p4"
	quit
	;
	; ---------------------------------------------------------------------------------------------
nord	; noreadonly with stderr= : the direction iopi_open.c gave the device must survive it
	open "p6":(shell="/bin/sh":command="echo to-stderr 1>&2":noreadonly:stderr="perr6")::"pipe"
	do chkread("perr6","to-stderr","the stderr device of a noreadonly PIPE can be READ")
	do chkerr("W","perr6","DEVICEREADONLY","a WRITE to that stderr device is still refused")
	use $principal close "p6"
	quit
	;
	; ---------------------------------------------------------------------------------------------
chkread(dev,want,what)	; READ every line dev gives and compare with "want"
	new got,x,err
	set (got,err)=""
	new $etrap set $etrap="set err=$$mnemonic($zstatus) set $ecode="""" goto chkreadd"
	use dev
	for  read x quit:$zeof  set got=got_$select(""=got:"",1:",")_x
chkreadd	;
	use $principal
	if ""'=err write "FAIL : ",what," : the READ failed with ",err,!  quit
	if got=want write "PASS : ",what,", and gave [",got,"]",!
	else  write "FAIL : ",what,". Expected [",want,"], got [",got,"]",!
	quit
	;
chkerr(op,dev,want,what)	; the named operation on dev must fail, with mnemonic "want"
	new got,x
	set got=""
	new $etrap set $etrap="set got=$$mnemonic($zstatus) set $ecode="""" goto chkerrd"
	if "R"=op use dev read x
	if "W"=op use dev write "x"
chkerrd	;
	use $principal
	if got=want write "PASS : ",what," (",got,")",!
	else  write "FAIL : ",what,". Expected ",want,", got [",$select(""=got:"no error at all",1:got),"]",!
	quit
	;
mnemonic(zst)	; "150373850,lab+1^rtn,%YDB-E-DEVICEREADONLY, Cannot ..." -> "DEVICEREADONLY"
	quit $piece($piece(zst,",",3),"-",3)
