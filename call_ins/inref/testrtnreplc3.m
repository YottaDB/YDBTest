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
; This routine is invoked merrily to (re)allocate the space freed up when (if) the original version
; of testrtnreplcA was replaced.
;
testrtnreplc3
	write "testrtnreplc3: Entered - set 3 (different) var with different values",!
	set x=-1,y=0,z=1
	write "testrtnreplc3: Returning",!
	quit
