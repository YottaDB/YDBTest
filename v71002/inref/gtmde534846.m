;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtmde534846 ;
	; Set $ETRAP to handle possible YDB-W-TIMEOUT in case $ZTIMEOUT times out.
	; In that case, there is no legitimate failure since 0 cannot be greater than
	; the difference between the duration of a HANG. So, just continue with the
	; test in that case by calling DO ^incretrap.
	set $ztrap="goto incrtrap^incrtrap"
	set incrtrapNODISP=1
	set initial(0)=0.1,hangtime(0)=0.045
	set initial(1)=.012345,hangtime(1)=0.005
	set initial(2)=.002345,hangtime(2)=0.001

	for i=0:1:2  do
	. set $ztimeout=initial(i)
	. hang hangtime(i)
	. set out(i)=$ztimeout	; Store value of $ZTIMEOUT to be output later rather than immediately, to prevent WRITE from being interrupted in case $ZTIMEOUT expires
	set $ztimeout=-1	; Clear the timer so it doesn't expire before results are output

	; Output the value of $ZTIMEOUT for each scenario
	for i=0:1:2  do
	. if ((0>=out(i))!(out(i)>=(initial(i)-hangtime(i))))  do
	. . write "FAIL: $ztimeout="_out(i)_", but expected < "_(initial(i)-hangtime(i)),!
	. else  do
	. . write "$ZTIMEOUT="""_out(i)_"""",!

	quit
