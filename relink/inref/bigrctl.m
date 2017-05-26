;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Do a 1M + 1 ZRUPDATEs on unique (existing) files, expecting all but the last to work smoothly.
; Upon finishing, validate the cummulative RCTLDUMP in-process.
bigrctl
	new i,error,prefix,rctldump

	set prefix=$zcmdline
	do
	.	new $etrap
	.	set $etrap="set i=i-1 write $zstatus,! set $ecode="""""
	.	for i=1:1:1000001 zrupdate prefix_"/f"_i_".o"
	write "Successfully ZRUPDATEd "_i_" files.",!
	if $$^rctldump(-1,$zparse(prefix,"NAME"),1000000,.error,.rctldump) do
	.	write "TEST-E-FAIL, "_error,!
	.	zshow rctldump
	.	zhalt 1
	write "TEST-I-SUCCESS, Test succeeded."
	quit
