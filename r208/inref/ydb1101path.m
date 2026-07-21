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
; OPEN a PIPE device with the PARSE deviceparameter and a command that exists in none of the $PATH
; directories, so parse_pipe() walks every one of them. parse_pipe() first copies $PATH into a
; YDB_PATH_MAX (PATH_MAX+1) byte buffer, truncating anything longer. The truncated copy used to be
; left unterminated, so the STRTOK_R that splits it on ":" ran off the end of the buffer.
;
; The caller (pipe_parse_longpath-ydb1101.csh) is responsible for making $PATH exceed PATH_MAX.
;
ydb1101path	;
	new $etrap
	set $etrap="do report set $ecode="""" quit"
	write "# OPEN a PIPE device with PARSE while $PATH is longer than YDB_PATH_MAX (PATH_MAX+1)",!
	write "# $PATH is longer than PATH_MAX (4096): ",(4096<$length($ztrnlnm("PATH"))),!
	open "pp":(command="ydb1101nosuchcommand":parse)::"pipe"
	write "# FAIL: the OPEN unexpectedly succeeded",!
	close "pp"
	quit
	;
report	; report on the DEVOPENFAIL the OPEN above is expected to have raised
	write "# DEVOPENFAIL=",(0'=$find($zstatus,"DEVOPENFAIL"))," after searching every $PATH directory",!
	write "# PASS: parse_pipe walked the truncated $PATH without reading past the end of the buffer",!
	quit
