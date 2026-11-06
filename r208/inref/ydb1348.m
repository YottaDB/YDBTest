;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
; Helper M program used by the r208/socket_block_mnemonic-ydb1348 subtest. Each label does one WRITE /mnemonic to a
; listening socket and prints PASS or FAIL, depending on whether it issued the expected error (or no error).
;
long	; A mnemonic that starts with BLOCK and is longer than it
	do check("/BLOCKG121","INVCTLMNE")
	quit
b	; The 1-character prefix of BLOCK
	do check("/B(""OFF"")","INVCTLMNE")
	quit
blo	; A 3-character prefix of BLOCK
	do check("/BLO(""CLEAR"")","INVCTLMNE")
	quit
blocks	; BLOCK followed by one more character
	do check("/BLOCKS(""CLEAR"")","INVCTLMNE")
	quit
block	; BLOCK, in upper and lower case
	do check("/BLOCK(""CLEAR"")","")
	do check("/block(""CLEAR"")","")
	quit
check(mnemonic,expect)
	; Do "WRITE <mnemonic>" to a listening socket and check the error it issues ("" for no error)
	new s,err,z
	set s="ydb1348sock"
	open s:(LISTEN="0:TCP"):5:"SOCKET"
	use s
	set err=""
	do
	. new $etrap
	. set $etrap="set err=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""" quit"
	. xecute "write "_mnemonic
	use $principal
	close s
	if err=expect write "PASS : WRITE ",mnemonic," issued ",$select(""=err:"no error",1:err),!
	else  write "FAIL : WRITE ",mnemonic," issued ",$select(""=err:"no error",1:err)," instead of ",$select(""=expect:"no error",1:expect),!
	quit
