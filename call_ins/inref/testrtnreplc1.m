;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; See replace_rtn.csh for a description of this test
;
testrtnreplc1
	write "testrtnreplc1: Entered - initialize some vars to play with",!
	set a=42,b=4242,c=424242
	write "testrtnreplc1: Driving call-in",!
	do ^testrtnreplcA	; Placing this routine on the stack for now but will mod it later
	write "testrtnreplc1: Back in testrtnreplc1 - variable values:",!
	zshow "V"
	quit
