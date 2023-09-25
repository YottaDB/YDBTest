;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; v70001/gtm9213 - Test that we can set the trailing portion of the $SYSTEM value
gtm9213
	set err=0
	set startsysval=$system
	write !,"# Initial value of $SYSTEM: "
	zwrite $system
	write !,"# Set ',a multi-word extended value' as the trailing portion of $SYSTEM",!
	set $system=",a multi-word extended value"	; Prepend a ',' separator
	if $system'=(startsysval_",a multi-word extended value") do
	. write "$SYSTEM value: ",$system,!
	. write "Expected:      ",startsysval,",a multi-word extended value",!
	. if $incr(err)
	else  write "  ** Got expected value: ",$system,!
	; Make sure we can change it and make sure the old buffer doesn't come along for the ride as
	; we set a shorter value into $SYSTEM.
	write !,"# Set ',a different shorter value' as the tailing portion of $SYSTEM",!
	set $system=",a different shorter value"
	if $system'=(startsysval_",a different shorter value") do
	. write "$SYSTEM value: ",$system,!
	. write "Expected:      ",startsysval,",a different shorter value",!
	. if $incr(err)
	else  write "  ** Got expected value: ",$system,!
	; Make sure we can un-set by setting a null
	write !,"# Set empty string as the trailing portion of $SYSTEM",!
	set $system=""
	if $system'=startsysval do
	. write "$SYSTEM value: ",$system,!
	. write "Expected:      ",startsysval,!
	. if $incr(err)
	else  write "  ** Got expected value: ",$system,!
	; Error check
	write:err=0 !,"PASS gtm9213",!
	write:err'=0 !,"FAIL gtm9213",!

