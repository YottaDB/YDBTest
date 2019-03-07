;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dsystem ; ; ; test $system
;       New (act)
	If '$Data(act) New act Set act="W !,gtmsid,! ZP @$ZPOS"
	Set cnt=0
	Set gtmsid=$select(""'=$ztrnlnm("ydb_sysid"):$ztrnlnm("ydb_sysid"),1:$ztrnlnm("gtm_sysid"))
	If "47,"'=$Extract($SYstem,1,3) set cnt=cnt+1 Xecute act
	If $Select($Length(gtmsid):gtmsid,1:"gtm_sysid")'=$Extract($system,4,9999) set cnt=cnt+1 Xecute act
	Write !,$Select(cnt:"FAIL",1:"PASS")," from ",$Text(+0),!
	Quit
