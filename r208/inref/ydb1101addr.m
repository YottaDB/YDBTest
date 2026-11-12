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
ydb1101addr	; Called by r208/u_inref/fuzz_asserts9-ydb1101.csh. Each stageN label is a stage. An error is reported as
	; "error=<mnemonic>".
	quit
stage1	; OPEN of a socket with an empty LISTEN address
	new s
	set $etrap="do err^ydb1101addr"
	set s="socdev"
	do open1(s)
	write "end",!
	quit
open1(s)	; the OPEN in a frame of its own, so that the stage goes on after the error
	open s:(listen="")::"socket"
	quit
stage2	; OPEN of a socket with an empty CONNECT address
	new s
	set $etrap="do err^ydb1101addr"
	set s="socdev"
	do open2(s)
	write "end",!
	quit
open2(s)	; the OPEN in a frame of its own, so that the stage goes on after the error
	open s:(connect="")::"socket"
	quit
err	; report the mnemonic of the error and go on with the next line of the stage
	use $principal
	write "error=",$piece($piece($zstatus,",",3),"-",3),!
	set $ecode=""
	quit
