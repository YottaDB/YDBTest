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
ydb1386	; Called by r208/u_inref/fnname_extref-ydb1386.csh. Each stageN label is a stage. An error is reported as
	; "error=<mnemonic>".
	quit
stage1	; $NAME() of an indirect global name with an extended reference that has no environment
	set $etrap="do err^ydb1386"
	do name("^[")
	write "end",!
	quit
stage2	; $NAME() of an indirect global name with an extended reference that has no second environment
	set $etrap="do err^ydb1386"
	do name("^[1,")
	write "end",!
	quit
name(x)	; the $NAME() in a frame of its own, so that the stage goes on after the error
	write $name(@x),!
	quit
err	; report the mnemonic of the error and go on with the next line of the stage
	use $principal
	write "error=",$piece($piece($zstatus,",",3),"-",3),!
	set $ecode=""
	quit
