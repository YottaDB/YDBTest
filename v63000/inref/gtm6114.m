;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm6114	;Verify ZMESSAGE with indirection in its arguments produces the appropriate error and $ZSTATUS
	;
	new (oops,debug)
	if '$data(oops) new oops set oops="if $increment(cnt) use $principal zshow ""v"""
	new $etrap,$estack
	set $ecode="",$etrap="do ^incretrap"
	do nogbls^incretrap
	set incretrap("EXPECT")="UNDEF",incretrap("NODISP")=1
	set a="150373850:x",c="x",ia="@a",ic="c",im="m",m=150373850
	zmessage m
	set $zstatus=""
	zmessage m:c
	if $zstatus'["variable: x",$increment(cnt) xecute oops
	set $zstatus=""
	zmessage m:@ic
	if $zstatus'["variable: x",$increment(cnt) xecute oops
	set $zstatus=""
	zmessage @m
	set $zstatus=""
	zmessage @im
	set $zstatus=""
	zmessage @im:c
	if $zstatus'["variable: x",$increment(cnt) xecute oops
	set $zstatus=""
	zmessage @im:@ic
	if $zstatus'["variable: x",$increment(cnt) xecute oops
	set $zstatus=""
	zmessage @(m_":"_c)
	if $zstatus'["variable: x",$increment(cnt) xecute oops
	set $zstatus=""
	zmessage @ia
	if $zstatus'["variable: x",$increment(cnt) xecute oops
	write !,$select('$get(cnt):"PASS",1:"FAIL")," from ",$text(+0),!
	quit
