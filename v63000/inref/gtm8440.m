;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8440	; demonstrate issue with get_log_name v_len is unsigned and call from USE can overflow
	;
	new (act)
	if '$data(act) new act set act="if $increment(cnt) use $principal zshow ""*"""
	do nogbls^incretrap
	new $etrap,$estack
	set $ecode="",$etrap="do ^incretrap"
	set toobig=$translate($justify("",2**20-1)," ","a")
	set expect="INVSTRLEN"
	open toobig
	open toobig:::"PIPE"
	open toobig:::"SOCKET"
	use toobig
	set expect="LOGTOOLONG"
	close toobig
	write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0)
	quit
