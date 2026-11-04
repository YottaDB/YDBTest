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
ydb1101sock	; Called by r208/u_inref/fuzz_asserts5-ydb1101.csh. Each stageN label is a stage. An error is reported as
	; "error=<mnemonic>".
	quit
stage1	; OPEN of a listening socket with an empty handle
	new s,k
	set $etrap="do err^ydb1101sock"
	set s="socdev"
	open s:(listen="0:TCP":attach="")::"socket"
	use s
	write /listen(1)
	set k=$key
	use $principal
	write "$key starts with ",$piece(k,"|",1),"|",$piece(k,"|",2),"|",!
	close s
	write "end",!
	quit
stage2	; a second OPEN of the same device with the same empty handle
	new s
	set $etrap="do err^ydb1101sock"
	set s="socdev"
	open s:(listen="0:TCP":attach="")::"socket"
	do open2(s)
	close s
	write "end",!
	quit
open2(s)	; the second OPEN of stage2, in a frame of its own, so that stage2 goes on after the error
	open s:(listen="0:TCP":attach="")::"socket"
	quit
stage3	; OPEN of a connecting socket with an empty handle
	new s,c,k,p
	set $etrap="do err^ydb1101sock"
	set s="socdev"
	open s:(listen="0:TCP":attach="h1")::"socket"
	use s
	write /listen(1)
	set p=$piece($key,"|",3)
	use $principal
	set c="client"
	open c:(connect="127.0.0.1:"_p_":TCP":attach="")::"socket"
	use c
	set k=$key
	use $principal
	write "$key starts with ",$piece(k,"|",1),"|",$piece(k,"|",2),"|",!
	close c,s
	write "end",!
	quit
err	; report the mnemonic of the error and go on with the next line of the stage
	use $principal
	write "error=",$piece($piece($zstatus,",",3),"-",3),!
	set $ecode=""
	quit
