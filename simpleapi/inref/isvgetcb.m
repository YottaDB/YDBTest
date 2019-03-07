;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to test ISV fetching via ydb_get_s() simpleAPI interface
;
; Create a piece string delimited by '|' (won't appear in any values) that contains the name of the ISVs we want to
; fetch via the simpleAPI. Send this list to an external call that will call back in via ydb_get_s() to fetch the
; values for the given set of ISVs and return a delimited string of the values that this routine can compare.
;
; Notes:
;  1. Care must be taken in chosing the ISVs to fetch since they will be fetched by this program before calling the
;     external call. So values must not be things that will change. For example, $ZREALSTOR, $HOROLOG, are examples
;     of ISVs we cannot verify because they can change moment to moment.
;  2. Because $ZSTATUS is one of the values we wish to validate, the validation takes place inside the error handler
;     that created the $ZSTATUS (undefined variable error we purposely create) so $ZSTATUS is not cleared by "handling"
;     the error.
;
isvgetcb
	write "isvgetcb: entered function - fetch ISV values",!
	set ($etrap,baseetrap)="write ""Error occurred: "",$zstatus,! zshow ""*"" zhalt 1"	; General error handler
	;
	; Build piece string of ISV names and another of the expected values
	;
	set ISVindx=1
	set $zpiece(ISVnames,"|",ISVindx)="$ETRAP",$zpiece(ISVvalues,"|",ISVindx)=$etrap,ISVindx=ISVindx+1
	set $zpiece(ISVnames,"|",ISVindx)="$IO",$zpiece(ISVvalues,"|",ISVindx)=$io,ISVindx=ISVindx+1
	set $zpiece(ISVnames,"|",ISVindx)="$JOB",$zpiece(ISVvalues,"|",ISVindx)=$job,ISVindx=ISVindx+1
	set $zpiece(ISVnames,"|",ISVindx)="$PRINCIPAL",$zpiece(ISVvalues,"|",ISVindx)=$principal,ISVindx=ISVindx+1
	set $zpiece(ISVnames,"|",ISVindx)="$SYSTEM",$zpiece(ISVvalues,"|",ISVindx)=$system,ISVindx=ISVindx+1
	set $zpiece(ISVnames,"|",ISVindx)="$ZDIRECTORY",$zpiece(ISVvalues,"|",ISVindx)=$zdirectory,ISVindx=ISVindx+1
	set $zpiece(ISVnames,"|",ISVindx)="$ZGBLDIR",$zpiece(ISVvalues,"|",ISVindx)=$zgbldir,ISVindx=ISVindx+1
	set $zpiece(ISVnames,"|",ISVindx)="$ZINTERRUPT",$zpiece(ISVvalues,"|",ISVindx)=$zinterrupt,ISVindx=ISVindx+1
	set $zpiece(ISVnames,"|",ISVindx)="$ZIO",$zpiece(ISVvalues,"|",ISVindx)=$zio,ISVindx=ISVindx+1
	set $zpiece(ISVnames,"|",ISVindx)="$ZKEY",$zpiece(ISVvalues,"|",ISVindx)=$zkey,ISVindx=ISVindx+1	; test null value
	set $zpiece(ISVnames,"|",ISVindx)="$ZPROMPT",$zpiece(ISVvalues,"|",ISVindx)=$zprompt,ISVindx=ISVindx+1
	set $zpiece(ISVnames,"|",ISVindx)="$ZROUTINES",$zpiece(ISVvalues,"|",ISVindx)=$zroutines,ISVindx=ISVindx+1
	set $zpiece(ISVnames,"|",ISVindx)="$ZVERSION",$zpiece(ISVvalues,"|",ISVindx)=$zversion,ISVindx=ISVindx+1
	set $zpiece(ISVnames,"|",ISVindx)="$ZYRELEASE",$zpiece(ISVvalues,"|",ISVindx)=$ZYRELEASE,ISVindx=ISVindx+1
	;
	; Drive an error to set $zstatus
	;
	write "isvgetcb: resetting $etrap for purposeful UNDEF error",!
	set $etrap="do isvgetcbcont"
	set x=IamANundefinedVAR			; Drive an (expected) UNDEF error to get us to the handler
	write "isvgetcb: Error - UNDEF error did not occur - unexpected result",!
	zshow "*"
	zhalt 1

;
; This is technically an "error handler" but since we want a stable environment that $zstatus stays in its current
; form, we'll go ahead and drive the fetches from this "error handler" environment. First fetch and save the value
; so we can compare it later.
;
isvgetcbcont
	new errnum
	write "isvgetcb: Error handler now in control - fetching $ZSTATUS and driving isvgetcb",!
	set errnum=+$zstatus			; Get actual error value
	do:(150373850'=errnum) @baseetrap	; Drive base etrap handler if not the error we expect
	set $etrap=baseetrap			; Put default handler back into use
	set $zpiece(ISVnames,"|",ISVindx)="$ZSTATUS",$zpiece(ISVvalues,"|",ISVindx)=$zstatus,ISVindx=ISVindx+1
	;
	; Now drive external call that will call back in via ydb_get_s() to fetch these same ISVs and their values
	; returning a value string to us that we can compare.
	;
	do &isvgetcb(.ISVnames,.ISVvals)
	;
	; We now can compare the two strings we built. A simple compare is sufficient for equality but if there's
	; a difference, we'll need to break it down to what differed and how.
	;
	if (ISVvals=ISVvalues) write "isvgetcb: Success - Output value (len ",$zlength(ISVvalues),") has the expected value",!
	else  do
	. new i
	. write "isvgetcb: Output value differs from expected - details follow:",!
	. for i=1:1 do  quit:(""=isv)
	. . set isv=$zpiece(ISVnames,"|",i)
	. . quit:(""=isv)
	. . set isvexpval=$zpiece(ISVvalues,"|",i)
	. . set isvactval=$zpiece(ISVvals,"|",i)
	. . write "ISV: ",isv,!,"   Expected Value: ",?20,isvexpval,!,"   Actual Value: ",?20,isvactval
	. . write:(isvexpval'=isvactval) "   ** Mismatch**"
	. . write !
	write !,"isvgetcb: Complete",!
	zhalt 0
