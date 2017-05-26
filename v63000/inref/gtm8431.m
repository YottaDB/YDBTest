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
gtm8431	;Validate $TEXT() of ^GTM$DMOD or ^GTM$CI returns an empty string not produces a RPARENMISSING
	;
	new (oops,debug)
	if '$data(oops) new oops set oops="if $increment(cnt) use $principal zshow ""v"""
	new $etrap,$estack
	set $ecode="",$etrap="do ^incretrap"
	do nogbls^incretrap
	if $length($text(^GTM$DMOD)),$increment(cnt) xecute ops
	if $length($text(^GTM$CI)),$increment(cnt) xecute ops
	for rtn="^GTM$DMOD","^GTM$CI" if $length($text(@rtn)),$increment(cnt) xecute ops
	set incretrap("EXPECT")="RPARENMISSING",incretrap("NODISP")=1
	for rtn="^GTM$DMO","^GTM$DMODS","^GTM$C","^GTM$C" do
	. write $text(@rtn)
	write !,$select('$get(cnt):"PASS",1:"FAIL")," from ",$text(+0),!
	quit
	; the lines below should all issue compiler warnings - no need to execute them
	write $text(^GTM$DMO)
	write $text(^GTM$DMODS)
	write $text(^GTM$C)
	write $text(^GTM$CIS)
