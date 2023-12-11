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
; This test verifies the only part of this issue not verified by other tests in the
; test system - that when the code argument is either not present or it is null.
gtm9388
	write !,"# Execute a ZBREAK at zbreaknop with a non-existant code argument to see what happens:",!
	write "# Command run: ZBREAK zbreaknop followed by ZSHOW ""B""",!
	zbreak zbreaknop		; This entry point WOULD cause a ZBREAK if we ran it so not doing that here
	zshow "B"
	write !,"# Execute a ZBREAK at zbreaknop with a null-string code argument to see what happens:",!
	write "# Command run: ZBREAK zbreaknop:"""" followed by ZSHOW ""B""",!
	zbreak zbreaknop:""	; This entry point is a NO-OP due to null code
	zshow "B"
	write !,"# Drive zbreaknop entry point to verify this does not break",!
	do zbreaknop
	quit

;
; Entry point to demonstrate that ZBREAKs with no code attached are just glorified NO-OPs.
;
zbreaknop
	write "Entry point reached with no problem",!
	quit

