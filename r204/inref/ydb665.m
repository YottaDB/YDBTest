;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

zinthandle ;
	kill ^y  lock +y  set $ZINTERRUPT="set ^y=1  lock -y"
	write "# Set $REFERENCE and wait for the interrupt to run",!
	set ^x(1)=1  for  zshow "L":locks  quit:'$data(locks("L",1))  hang .1
	write "# Verify that $REFERENCE is still ^x(1) and that we have set ^y",!
	write "$REFERENCE="_$REFERENCE,!
	write "^y="_^y,!
	quit

waitinterrupt ;
	write "# Wait up to 30 seconds for zinthandle^ydb665 to signal that an interrupt was received"
	for i=0:1:300 quit:($data(^x(1))'=0)  hang .1
	quit
