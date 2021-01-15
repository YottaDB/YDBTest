;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb678	;
	quit

zshow	;
	zwrite $ZYINTRSIG,$ZININTERRUPT
	quit

zshowonsigusr1	;
	set $zinterrupt="do zshow^ydb678"
	; MUPIP INTRPT and kill -SIGUSR1 are equivalent so try both
	write "# Trying KILL -SIGUSR1 on pid",!
	if $zsigproc($job,"sigusr1")
	write !
	write "# Trying MUPIP INTRPT on pid",!
	zsystem "$ydb_dist/mupip intrpt "_$job
	quit

zshowonsigusr2	;
	set $zinterrupt="do zshow^ydb678"
	if $zsigproc($job,"sigusr2")
	quit

setisv	;
	xecute "set $zyintrsig=$zyrelease"	; use xecute to avoid compile-time errors
	quit
