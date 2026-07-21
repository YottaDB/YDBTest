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
; OPEN a PIPE device with the PARSE deviceparameter and a COMMAND= whose first command word cannot be
; resolved to an executable. parse_pipe() copies that word into the caller's fixed size "ret_token"
; buffer (GTM_MAX_DIR_LEN bytes) to build the "Invalid command string" message. The copy used to be an
; unbounded memcpy guarded only by a DEBUG-build assert, while COMMAND= itself may be up to MAX_STRLEN
; (1MiB) long, so a long first command word overran that stack buffer.
;
; A leading "/" keeps the word a single token that is looked up as a path (and so is not found), and
; none of " >&;|" appears in it so the tokenizer hands the whole thing over in one piece.
;
ydb1101pipe	;
	new len
	write "# OPEN a PIPE device with PARSE and an unresolvable COMMAND= word of increasing length",!
	write "# The command word is copied into a GTM_MAX_DIR_LEN (2*PATH_MAX) buffer; COMMAND= may be 1MiB",!
	; 4096 straddles the YDB_PATH_MAX bound the old assert tested, 8191/8192/8193 straddle the
	; GTM_MAX_DIR_LEN bound of the buffer itself, and 1000000 approaches MAX_STRLEN.
	for len=100,4096,8191,8192,8193,1000000 do try(len)
	write "# PASS: every OPEN failed cleanly with a bounded error token and no buffer overrun",!
	quit
	;
try(len)	; attempt one OPEN with a command word "len" characters long
	new cmd,$etrap
	set $etrap="do report(len) set $ecode="""" quit"
	set cmd="/"_$translate($justify(" ",len)," ","a")
	open "pp":(command=cmd:parse)::"pipe"
	write "# cmdlen=",len," FAIL: the OPEN unexpectedly succeeded",!
	close "pp"
	quit
	;
report(len)	; report on the DEVOPENFAIL the OPEN above is expected to have raised
	new toklen
	set toklen=$length($piece($zstatus,"Invalid command string: ",2))
	write "# cmdlen=",len," DEVOPENFAIL=",(0'=$find($zstatus,"DEVOPENFAIL"))," errtokenlen=",toklen,!
	quit
